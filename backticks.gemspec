# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'backticks/version'

Gem::Specification.new do |spec|
  spec.name          = 'backticks'
  spec.version       = Backticks::VERSION
  spec.authors       = ['Tony Spataro']
  spec.email         = ['xeger@xeger.net']

  spec.summary       = %q{Intuitive OOP wrapper for command-line processes}
  spec.description   = %q{Captures stdout, stderr and (optionally) stdin; uses PTY to avoid buffering.}
  spec.homepage      = 'https://github.com/xeger/backticks'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 2.0', '< 4.0')

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
end
