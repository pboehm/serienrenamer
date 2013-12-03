# -*- encoding: utf-8 -*-
require File.expand_path('../lib/serienrenamer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Philipp Böhm"]
  gem.email         = ["philipp@i77i.de"]
  gem.description   = %q{Ruby Script that brings your series into an appropriate format like \"S01E01 - Episodename.avi\"}
  gem.summary       = %q{Ruby Script that brings your series into an appropriate format like \"S01E01 - Episodename.avi\"}
  gem.homepage      = "http://github.com/pboehm/serienrenamer"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "serienrenamer"
  gem.require_paths = ["lib"]
  gem.version       = Serienrenamer::VERSION

  gem.required_ruby_version = '>= 1.9.0'
  gem.add_runtime_dependency(%q<wlapi>, [">= 0.8.5"])
  gem.add_runtime_dependency(%q<mediawiki-gateway>, [">= 0.4.4"])
  gem.add_runtime_dependency(%q<mechanize>, [">= 2.3"])
  gem.add_runtime_dependency(%q<highline>, [">= 1.6.11"])
  gem.add_runtime_dependency(%q<hashconfig>, [">= 0.0.1"])
end
