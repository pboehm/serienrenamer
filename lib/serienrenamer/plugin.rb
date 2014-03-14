module Serienrenamer

  # Base plugin from which all exisiting plugins inherits
  class Pluginbase

    class << self; attr_reader :registered_plugins end
    @registered_plugins = []

    # if you inherit from this class, the child
    # gets added to the "registered plugins" array
    def self.inherited(child)
      self.registered_plugins << child
    end

    def self.plugin_name; "PluginBase" end
    def self.type; :information end        # or :filter

    def self.to_s
      self.plugin_name
    end

    # Is required because Ruby 2.0 prints the whole fully qualified class name
    def self.inspect
      return self.to_s
    end
  end

  # include all existing plugins
  module Plugin
    Dir[File.dirname(__FILE__) + '/plugin/*.rb'].each {|file| require file }
  end
end
