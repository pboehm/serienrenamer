$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))


module Serienrenamer
    VERSION = '0.0.6'

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

    # reopening Hash class and added a persistence method
    require 'yaml'

    class ::Hash

        # this method merges a YAML-serialized hash-instance
        # with self. if the given File is not exisiting this will write
        # a serialized version of self to this file.
        #
        # if the given yaml file does not contain a serialized hash than it
        # merges with an empty hash that returns self unchanged.
        #
        # returns a new Hash merged with deserialized version from the file
        def merge_with_serialized(yaml_file)

            unless File.file? yaml_file
                File.open(yaml_file, 'w') {|f| f.write(self.to_yaml) }
            end

            persistent_config = YAML.load(File.new(yaml_file, "rb").read)
            persistent_config = Hash.new unless persistent_config.is_a? Hash

            config = self.merge(persistent_config)
            File.open(yaml_file, 'w') {|f| f.write(config.to_yaml) }

            return config
        end
    end
end
