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
    # with an Serienrenamer::Episode instance or a path
    # to to a directory as parameter
    #
    # it returns an array of episode information
    def self.generate_episode_information(episode)

        sourcedir = ""
        if episode.is_a?(Serienrenamer::Episode)
            sourcedir = episode.source_directory
        elsif File.directory?(episode)
            sourcedir = episode
        else
            raise ArgumentError, "Serienrenamer::Episode or Path needed"
        end

        matched_episodes = []

        if Dir.exists?(sourcedir)

            # search for files that are smaller than 128 Bytes
            # an check if they contain episode information
            Dir.new(sourcedir).each do |e|
                file = File.join(sourcedir, e)
                next if File.size(file) > 128 || File.zero?(file)

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
