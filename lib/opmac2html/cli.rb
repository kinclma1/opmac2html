require 'slop'
require 'opmac2html'
require 'opmac2html/converter'

module Opmac2html
  # Command line option parser and runner
  class CLI
    def initialize
      opts = Slop.parse(help: true) do |o|
        o.banner = 'Usage: opmac2html -i <input.tex> -o <output.html>'
        o.string '-i', '--input', 'Input OPmac file'
        o.string '-o', '--output', 'Output HTML file'
        o.on '-h', '--help', 'Shows this message'
        o.on '-v', '--version', 'Shows application version'
      end
      run opts
    end

    def run(opts)
      puts "opmac2html, version: #{Opmac2html.version}" if opts[:version]
      if opts[:input] && opts[:output]
        Converter.new(opts[:input], opts[:output]).convert
      else
        puts opts
      end
    end
  end
end
