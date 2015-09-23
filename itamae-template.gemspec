# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itamae/template/version'

Gem::Specification.new do |spec|
  spec.name          = "itamae-template"
  spec.version       = Itamae::Template::VERSION
  spec.authors       = ["Takashi Kokubun"]
  spec.email         = ["takashi-kokubun@cookpad.com"]

  spec.summary       = %q{The best practice for itamae}
  spec.description   = %q{Itamae template generater for roles and cookbooks.}
  spec.homepage      = "https://github.com/k0kubun/itamae-template"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
