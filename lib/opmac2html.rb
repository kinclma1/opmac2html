require 'opmac2html/version'
require 'opmac2html/converter'

module Opmac2html
  # Opmac2html root class/facade
  class Opmac2html
    def initialize(input, output)
      Converter.new(input, output).convert
    end

    def self.version
      VERSION
    end
  end
end
