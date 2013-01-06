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

    def self.to_s
      self.plugin_name
    end
  end

  # include all existing plugins
  module Plugin
    Dir[File.dirname(__FILE__) + '/plugin/*.rb'].each {|file| require file }
  end
end
