# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mantis_bug_reporter/version'

Gem::Specification.new do |spec|
  spec.name          = "mantis_bug_reporter"
  spec.version       = MantisBugReporter::VERSION
  spec.authors       = ["mangantj"]
  spec.email         = ["mangantj@gmail.com"]
  spec.description   = %q{Ties into Mantis api to create issues, add notes, and update issues.}
  spec.summary       = %q{Ties into Mantis api to create issues, add notes, and update issues.}
  spec.homepage      = "https://github.com/mangantj/mantis_bug_reporter"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "savon", "~> 1.2.0"
end
