require 'yaml'

module Serienrenamer

    # this class holds a storage for episode information (seriesname)
    # in form of a yaml file which can be used from other tools
    class InformationStore

        attr_reader :episode_hash

        # this method will load an exisiting yaml file and tries to rebuild
        # the used hash with episode data
        def initialize(yaml_path)
            @yaml_path = yaml_path
            @episode_hash = {}

            if File.file?(yaml_path)
                @episode_hash = YAML.load(File.new(yaml_path, "rb").read)
            end
        end

        # this method will store the information of the supplied episode
        # instance to the file
        def store(episode)
            raise ArgumentError, "Episode instance needed" unless
                episode.is_a? Serienrenamer::Episode

            unless @episode_hash[episode.md5sum]
                @episode_hash[episode.md5sum] = episode.series
            end
        end

        # this method will write the current hash of episodes to the
        # yaml file
        def write()
            storage_file = File.new(@yaml_path, "w")
            storage_file.write(@episode_hash.to_yaml)
            storage_file.close
        end
    end

end
