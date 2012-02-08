#
# Class that extracts information about episodes
# from the serienjunkies.org-Feed
#
require 'rss'
require 'open-uri'

class SeriejunkiesOrgFeed < Plugin

    PLUGIN_NAME = "SeriejunkiesOrgFeed"
    USABLE = true
    PRIORITY=10

    FEED_URL = 'http://serienjunkies.org/xml/feeds/episoden.xml'

    # this method will be called from the main program
    # with an Serienrenamer::Episode instance as parameter
    #
    # if this is the first call to this method, it builds up
    # a hash with all series and existing episodes, which can
    # be used by all future method calls
    #
    # it returns an updated version of the argument if a
    # suitable entry was found or nil if here was an
    # error or no suitable entry
    def self.generate_episode_information(episode)

        raise ArgumentError, "Serienrenamer::Episode instance needed" unless
            episode.is_a?(Serienrenamer::Episode)

        unless defined? @feed_data
            @feed_data = self.build_up_series_data
        end

        episode_definition = 'S%.2dE%.2d' % [ episode.season, episode.episode ]
        p episode_definition
        p episode.series

        # search for all items that match the definition
        # and save them uniquely in an array
        matched_definitions = []
        for epi in @feed_data.grep(/#{episode_definition}/)
            serdef = epi.match(/(^.*S\d+E\d+)/)[0]
            exist = matched_definitions.grep(/^#{serdef}/)[0]

            if exist != nil && epi.length > exist.length
                matched_definitions.delete(exist)
            elsif exist != nil && epi.length < exist.length
                next
            end

            matched_definitions.push(epi)
        end

        # find suitable episode string in the array of
        # matched definitions
        #
        # start with a pattern that includes all words from
        # Episode#series and if this does not match, it cuts
        # off the first word and tries to match again
        #
        # if the pattern contains one word and if this
        # still not match, the last word is splitted
        # characterwise, so that:
        #  crmi ==> Criminal Minds
        #
        matched_episodes = []
        name_words = episode.series.split(/ /)
        word_splitted = false

        while ! name_words.empty?

            pattern = name_words.join('.*')
            matched_episodes = matched_definitions.grep(/#{pattern}.*S\d+E\d+/i)
            break if ! matched_episodes.empty?

            # split characterwise if last word does not match
            if name_words.length == 1 && ! word_splitted &&
                    pattern.length % 2 == 0
                name_words = pattern.split(//)
                word_splitted = true
                next
            end

            name_words.delete_at(0)
        end

        return matched_episodes
    end

    private

    # create a list of exisiting episodes
    def self.build_up_series_data
        feed_data = []

        open(FEED_URL) do |rss|
            feed = RSS::Parser.parse(rss)
            feed.items.each do |item|
                feed_data.push(item.title.split(/ /)[1])
            end
        end
        return feed_data
    end
end
