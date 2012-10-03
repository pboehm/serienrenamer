# class that creates an episodename out of the episode identifier
# for S02E04 the episodename would be "Episode 4"

module Plugin

  class EpisodeIdentifier < Serienrenamer::Pluginbase

    def self.plugin_name; "EpisodeIdentifier" end
    def self.usable; true end
    def self.priority; 1 end

    # this method will be called from the main program
    # with an Serienrenamer::Episode instance or a path
    # to to a directory as parameter
    #
    # it returns an array of episode information
    def self.generate_episode_information(episode)

      path = episode.episodepath

      matched_episodes = []

      if Serienrenamer::Episode.contains_episode_information?(path)
        if md = Serienrenamer::Episode.extract_episode_information(path)
          episodename = "Episode %d" % [ md[:episode] ]
          matched_episodes << episodename
        end
      end

      return matched_episodes
    end
  end
end
