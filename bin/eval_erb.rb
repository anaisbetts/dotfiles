#!/usr/bin/ruby

require 'erb'
require 'CGI'

exit 1 unless ARGV.size == 2 or
              (ARGV.size == 1 and ARGV[0] =~ /\.eruby/)

if (ARGV.size == 2)
    (infile, outfile) = ARGV
else
    (infile, outfile) = [ARGV[0], ARGV[0].gsub(".eruby", '')]
end

File.open(outfile, 'w') do |out|
    out.puts(ERB.new(File.read(infile)).result(binding()))
end
