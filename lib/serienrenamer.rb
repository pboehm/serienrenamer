$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))


module Serienrenamer
    VERSION = '0.0.1'

    require 'serienrenamer/episode.rb'

    class Pluginbase

        class << self; attr_reader :registered_plugins end
            @registered_plugins = []

        # if you inherit from this class, the child
        # gets added to the "registered plugins" array
        def self.inherited(child)
            Pluginbase.registered_plugins << child
        end
    end

end
