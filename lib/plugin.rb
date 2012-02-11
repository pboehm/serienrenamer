$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'plugin/textfile.rb'
require 'plugin/serienjunkies_feed.rb'

module Plugin

end
