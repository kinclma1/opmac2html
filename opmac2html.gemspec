# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opmac2html/version'

Gem::Specification.new do |spec|
  spec.name          = "opmac2html"
  spec.version       = Opmac2html::VERSION
  spec.authors       = ["Martin Kinčl"]
  spec.email         = ["kinclma1"]
  spec.summary       = %q{Converter from OPmac TeX markup to HTML}
  spec.description   = %q{A converter of TeX documents written using OPmac macro set
                          to HTML5 pages}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "slop", "~> 4.0"
end
