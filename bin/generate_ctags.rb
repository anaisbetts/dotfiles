#!/usr/bin/ruby

############################
# Constants section - rig this as necessary
############################

Ctags_Parseable_Filetypes = { '.asp'=>'', '.awk'=>'', '.asm'=>'', '.c'=>'', '.cpp'=>'', 
			      '.c++'=>'', '.cxx'=>'', '.h'=>'', '.hpp'=>'', '.hxx'=>'', 
			      '.cs'=>'', '.htm'=>'', '.html'=>'', '.java'=>'', '.js'=>'', 
			      '.lisp'=>'', '.clisp'=>'', '.lua'=>'', '.pl'=>'', 
			      '.php'=>'', '.py'=>'', '.rb'=>'', '.sh'=>'', '.vim'=>'' }

Ctags_Flags = '--c++-kinds=+p --fields=+iaS --extra=+q --exclude="*.sql"'


# Standard library
require 'logger'
require 'optparse'
require 'optparse/time'
require 'pathname'
require 'singleton'

$logging_level = ($DEBUG ? Logger::DEBUG : Logger::ERROR)
#$logging_level = Logger::DEBUG

def convert_path_to_dos(path)
	return nil unless path
        path.gsub(/\/cygdrive\/(.)\//, '\1:\\').gsub("/", "\x5C")
end

def is_windows?
  processor, platform, *rest = RUBY_PLATFORM.split("-")
  platform == 'mswin32'
end

class App < Logger::Application
	include Singleton

	def initialize
		super(self.class.to_s)
		self.level = $logging_level
	end

	def count_valid_files(root_path, exit_greater_than = nil)
		log DEBUG, "Counting '#{root_path}'..."
		path = (root_path.is_a?(Pathname) ? root_path : Pathname.new(root_path))

		# Iterate through the directory
		file_count = 0
		path.find() do |entry| 
			next if (entry == path) 

			# If the file extension is in our list, add to the file count
			file_count += 1 if Ctags_Parseable_Filetypes[entry.extname] and entry.stat.file?

			# We do this so we don't end up counting files we don't need to
			break if exit_greater_than and file_count > exit_greater_than
		end

		log DEBUG, "Found #{file_count} files in '#{root_path}'"
		file_count
	end

	def tag_files_in_path(root_path, output_dir, max_filecount)
		to_invoke = []
		
		path = (root_path.is_a?(Pathname) ? root_path : Pathname.new(root_path))

		if count_valid_files(path, max_filecount) < max_filecount then
			dir_name = File.join(output_dir, path.basename)
			cmd = "ctags #{Ctags_Flags} -R -f #{dir_name} #{path}"
			cmd = (@options[:dosmode] ? convert_path_to_dos(cmd) : cmd)
			log INFO, "Queueing '#{cmd}'"
			return [cmd]
		end

		# It must've been too big. Split it into subdirectories and make a list of
		# regular files while we're at it
		files_to_index = []
		path.each_entry do |entry|
			next if ['.', '..'].include? entry.to_s
			full_path = path.join(entry)

			if full_path.stat.file?
				files_to_index << full_path if Ctags_Parseable_Filetypes[path.extname]
				next
			end

			next unless full_path.stat.directory?
			to_invoke += tag_files_in_path(full_path, output_dir, max_filecount)
		end

		return to_invoke unless files_to_index.length > 0
		if files_to_index.length > max_filecount then
			log ERROR, "#{path} is too big to be indexed currently (#{files.length} entries)"
			return []
		end
	
		cmd = "ctags #{Ctags_Flags} -f #{output_dir.join(path.basename)} \"#{files_to_index.join('" "')}\""
		cmd = (@options[:dosmode] ? convert_path_to_dos(cmd) : cmd)
		log INFO, "Queueing '#{cmd}'"
		to_invoke << cmd

		return to_invoke
	end

	def run_commands_sync(commands)
		commands.each do |x|
			log INFO, "Running '#{x}'..."
			system(x)
		end
	end

	def run_commands_async(commands, max_concurrent = 3)
		to_run = {}
		commands.each { |x| to_run[x] = nil }

		# This is broken right now because open3 doesn't cooperate. Run sync instead
		run_commands_sync(commands)
		return 

		if is_windows?
			begin
				['rubygems', 'win32/open3'].each {|x| require x}
			rescue
				puts "Async dependencies not installed (rubygems, win32-open3). Dropping back to sync mode"
				run_commands_sync(commands)
				return
			end
		end

		until to_run.keys.empty?
			# Poll our running commands and remove finished processes
			to_run.delete_if { |cmd,status| puts "Finished: '#{cmd}'" if (a = status and status.exited?); a }
			num_running = 0; to_run.values.each { |x| num_running += 1 if x }

			if(num_running >= max_concurrent)
				sleep 2
				next
			end

			# Run some processes
			num_to_run = max_concurrent - num_running
			run_now = to_run.select{|k,v| not v}[0..num_to_run]
			run_now.each do |kv|
				puts "Starting: '#{kv[0]}'..."
				unless (to_run[kv[0]] = Open3.popen3(kv[0]) { |i,o,e| i.puts ''})
					log ERROR, "Couldn't run '#{kv[0]}'!"
					to_run.delete kv[0]
				end
			end
		end
	end

	def parse(args)
		# Set the defaults here
		results = { :target => '.', :maxcount => 25000 }

		opts = OptionParser.new do |opts|
			opts.banner = "Usage: generate_ctags [options] /path/to/code/files"

			opts.separator ""
			opts.separator "Specific options:"

			opts.on('-t', "--target dir", "Directory to put tags in") do |x|
				results[:target] = x
			end

			opts.on('-s', "--scriptonly", "Only list the actions this program would take") do |x|
				results[:scriptonly] = x
			end

			opts.on('-m', '--maxcount n', "Maximum number of source files in one tag repository - default is 25000") do |x|
				if (results[:maxcount] = x.to_i()) == 0 then
					puts "Maximum file count must be a positive number"
					exit
				end 
			end
			
			opts.on('', '--dos', "Always output DOS pathnames, regardless of input") do |x|
				results[:dosmode] = x
			end

			opts.on('-f', '--fast', "Run commands asyncronously") do |x|
				results[:fast] = x
			end

			opts.separator ""
			opts.separator "Common options:"

			opts.on_tail("-h", "--help", "Show this message" ) do
				puts opts
				exit
			end

			opts.on('-d', "--debug", "Run in debug mode (Extra messages)") do |x|
				$logging_level = DEBUG
			end

			opts.on('-v', "--verbose", "Run verbosely") do |x|
				$logging_level = INFO 
			end

			opts.on_tail("--version", "Show version" ) do
				puts OptionParser::Version.join('.')
				exit
			end
		end

		opts.parse!(args);	results
	end

	def run
		# Set up logging
		self.level = $logging_level

		# Parse arguments
		begin
			@options = parse(ARGV)
		rescue OptionParser::MissingArgument
			puts 'Missing parameter; see --help for more info'
			exit
		rescue OptionParser::InvalidOption
			puts 'Invalid option; see --help for more info'
			exit
		end

		# Reset our logging level because option parsing changed it
		self.level = $logging_level

		log DEBUG, 'Starting application'

		if ARGV.empty?
			puts "Please specify a path for source files; see --help for more info"
			exit
		end

		# Figure out a list of things to do
		commands = tag_files_in_path(ARGV[0], @options[:target], @options[:maxcount])

		commands = commands.collect {|x| "start cmd.exe /C \"start #{x}\""} if is_windows? and @options[:fast]
		if @options[:scriptonly]
			commands.each {|x| puts x}
		else
			run_commands_sync(commands)
		end

		log DEBUG, 'Exiting application'
	end
end

$the_app = App.instance
$the_app.run
