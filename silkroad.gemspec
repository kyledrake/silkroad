# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'silkroad/version'

Gem::Specification.new do |spec|
  spec.name          = "silkroad"
  spec.version       = Silkroad::VERSION
  spec.authors       = ["Kyle Drake"]
  spec.email         = ["kyledrake@gmail.com"]
  spec.description   = %q{A fast, thread-safe, simple, lightweight, batchable, sober interface to the bitcoind JSON-RPC api.}
  spec.summary       = %q{A fast, thread-safe, simple, lightweight, batchable, sober interface to the bitcoind JSON-RPC api. Uses HTTPClient for high performance (http://bibwild.wordpress.com/2012/04/30/ruby-http-performance-shootout-redux).}
  spec.homepage      = "https://github.com/kyledrake/silkroad"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "addressable"
  spec.add_dependency "httpclient"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "yard"
end