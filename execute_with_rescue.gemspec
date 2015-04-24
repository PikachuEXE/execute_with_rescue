# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "execute_with_rescue/version"

Gem::Specification.new do |spec|
  spec.name          = "execute_with_rescue"
  spec.version       = ExecuteWithRescue::VERSION
  spec.authors       = ["PikachuEXE"]
  spec.email         = ["pikachuexe@gmail.com"]
  spec.summary       = <<-SUMMARY
    Execute code without writting rescue in methods with before and after hooks.
    You can also create some extensions yourself.
  SUMMARY
  spec.description   = <<-DESC
    Saves your from writing `begin...rescue...ensure...end` everywhere.
    This assumes you know how to use `rescue_from` not just within a controller.
  DESC
  spec.homepage      = "http://github.com/PikachuEXE/execute_with_rescue"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.2.0", "< 5.0.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "appraisal", "~> 2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its", "~> 1.0"
  spec.add_development_dependency "coveralls", ">= 0.7"
  spec.add_development_dependency "gem-release", ">= 0.7"
  spec.add_development_dependency "rubocop", "~> 0.30"

  spec.required_ruby_version = ">= 1.9.3"

  spec.required_rubygems_version = ">= 1.4.0"
end
