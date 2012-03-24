$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))


module Serienrenamer
    VERSION = '0.0.8'

    require 'serienrenamer/episode.rb'
    require 'serienrenamer/information_store.rb'

    class Pluginbase

        class << self; attr_reader :registered_plugins end
            @registered_plugins = []

        # if you inherit from this class, the child
        # gets added to the "registered plugins" array
        def self.inherited(child)
            Pluginbase.registered_plugins << child
        end

        def self.plugin_name; "PluginBase" end

        def self.to_s
            self.plugin_name
        end
    end
end
