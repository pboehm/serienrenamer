# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "serienrenamer"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Philipp Boehm"]
  s.date = "2012-03-03"
  s.description = "Ruby Script that brings your series into an appropriate format\nlike \"S01E01 - Episodename.avi\""
  s.email = ["philipp@i77i.de"]
  s.executables = ["serienrenamer"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "bin/serienrenamer", "lib/plugin.rb", "lib/plugin/serienjunkies_de.rb", "lib/plugin/serienjunkies_feed.rb", "lib/plugin/textfile.rb", "lib/plugin/wikipedia.rb", "lib/serienrenamer.rb", "lib/serienrenamer/episode.rb", "script/console", "script/destroy", "script/generate", "serienrenamer.gemspec", "test/serienjunkies_feed_sample.xml", "test/test_episode.rb", "test/test_helper.rb", "test/test_plugin_serienjunkies_de.rb", "test/test_plugin_serienjunkies_feed.rb", "test/test_plugin_textfile.rb", "test/test_plugin_wikipedia.rb", ".gemtest"]
  s.homepage = "http://github.com/pboehm/serienrenamer"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "serienrenamer"
  s.rubygems_version = "1.8.15"
  s.summary = "Ruby Script that brings your series into an appropriate format like \"S01E01 - Episodename.avi\""
  s.test_files = ["test/test_plugin_serienjunkies_de.rb", "test/test_plugin_wikipedia.rb", "test/test_plugin_serienjunkies_feed.rb", "test/test_plugin_textfile.rb", "test/test_helper.rb", "test/test_episode.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<wlapi>, [">= 0.8.4"])
      s.add_runtime_dependency(%q<mediawiki-gateway>, [">= 0.4.4"])
      s.add_runtime_dependency(%q<mechanize>, [">= 2.3"])
      s.add_runtime_dependency(%q<highline>, [">= 1.6.11"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<newgem>, [">= 1.5.3"])
      s.add_development_dependency(%q<hoe>, ["~> 2.13"])
    else
      s.add_dependency(%q<wlapi>, [">= 0.8.4"])
      s.add_dependency(%q<mediawiki-gateway>, [">= 0.4.4"])
      s.add_dependency(%q<mechanize>, [">= 2.3"])
      s.add_dependency(%q<highline>, [">= 1.6.11"])
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<newgem>, [">= 1.5.3"])
      s.add_dependency(%q<hoe>, ["~> 2.13"])
    end
  else
    s.add_dependency(%q<wlapi>, [">= 0.8.4"])
    s.add_dependency(%q<mediawiki-gateway>, [">= 0.4.4"])
    s.add_dependency(%q<mechanize>, [">= 2.3"])
    s.add_dependency(%q<highline>, [">= 1.6.11"])
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<newgem>, [">= 1.5.3"])
    s.add_dependency(%q<hoe>, ["~> 2.13"])
  end
end
