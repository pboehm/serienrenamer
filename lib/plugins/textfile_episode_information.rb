#
# Class that searches for a file with
# episode information in the directory
# like "episode.txt"
#

class TextfileEpisodeInfo < Plugin

    PLUGIN_NAME = "TxtEpisodeInfo"
    USABLE = true
    PRIORITY=100

    # this method will be called from the main program
    # with an Serienrenamer::Episode instance as parameter
    #
    # it returns an array of episode information
    def self.generate_episode_information(episode)

        raise ArgumentError, "Serienrenamer::Episode instance needed" unless
            episode.is_a?(Serienrenamer::Episode)

        matched_episodes = []

        if episode.source_directory && Dir.exists?(episode.source_directory)

            Dir.new(episode.source_directory).each do |e|
                file = File.join(episode.source_directory, e)
                next if File.size(file) > 1024 || File.zero?(file)

                data = File.open(file, "rb").read
                if data != nil && data.match(/\w+/) &&
                        Serienrenamer::Episode.contains_episode_information?(data)
                    matched_episodes.push(data)
                end
            end
        end

        return matched_episodes
    end
end
