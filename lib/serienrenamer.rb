$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))


module Serienrenamer
    VERSION = '0.0.1'

    require 'serienrenamer/episode.rb'
end
