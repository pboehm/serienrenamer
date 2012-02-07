class SeriejunkiesOrgFeed < Plugin
    PLUGIN_NAME="SeriejunkiesOrgFeed"

    def self.generate_episode_information(episode)
        puts "[#{PLUGIN_NAME}] - #{episode.to_s}"
    end

end
