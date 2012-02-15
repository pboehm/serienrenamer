$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))


module Plugin

    require 'plugin/textfile.rb'
    require 'plugin/serienjunkies_feed.rb'
    require 'plugin/wikipedia.rb'

end
