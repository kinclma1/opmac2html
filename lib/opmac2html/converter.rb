require 'opmac2html/html_builder'
require 'opmac2html/list_builder'
require 'opmac2html/par_builder'
require 'opmac2html/table_builder'
require 'opmac2html/preprocessor'
require 'opmac2html/text_cutter'
require 'opmac2html/paragraph_parser'
require 'opmac2html/macro_parser'

module Opmac2html
  # Converter from OPmac to html markup
  class Converter
    include TextCutter
    include ParagraphParser
    include MacroParser

    def initialize(input_file, output_file)
      @input = read_input input_file
      @preproc = Preprocessor.new
      @input = @preproc.run @input
      @builder = HtmlBuilder.new
      @output_file = output_file
      @ttchar = '"'
    end

    def read_input(filename)
      File.open(filename, 'r') { |input| input.readlines.join }
    end

    def write_output(output)
      File.open(@output_file, 'w') { |file| file << output }
    end

    def convert
      until @input.empty?
        if @input.start_with? '%', "\n"
          cut_at "\n"
        else
          parse
        end
        @input.lstrip!
      end
      write_output @builder.to_s
    end

    def parse
      if @input.start_with? '\\'
        parse_macro
      else
        parse_par
      end
    end

    def err(text)
      puts "Unsupported control sequence: #{text}"
    end
  end
end
