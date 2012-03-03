# encoding: UTF-8
require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/serienrenamer'
require './lib/plugin'

Hoe.plugin :newgem

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'serienrenamer' do
  self.developer 'Philipp Boehm', 'philipp@i77i.de'
  self.rubyforge_name       = self.name
  self.dependency('wlapi', '>= 0.8.4')
  self.dependency('mediawiki-gateway', '>= 0.4.4')
  self.dependency('mechanize', '>= 2.3')
  self.dependency('highline', '>= 1.6.11')
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
