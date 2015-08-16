# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lbrt/version'

Gem::Specification.new do |spec|
  spec.name          = 'lbrt'
  spec.version       = Lbrt::VERSION
  spec.authors       = ['Genki Sugawara']
  spec.email         = ['sgwr_dts@yahoo.co.jp']

  spec.summary       = %q{A tool to manage Librato. It defines the state of Librato using DSL, and updates Librato according to DSL.}
  spec.description   = %q{A tool to manage Librato. It defines the state of Librato using DSL, and updates Librato according to DSL.}
  spec.homepage      = 'https://github.com/winebarrel/lbrt'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'diffy'
  spec.add_dependency 'librato-client'
  spec.add_dependency 'parallel'
  spec.add_dependency 'term-ansicolor'
  spec.add_dependency 'thor'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
end
