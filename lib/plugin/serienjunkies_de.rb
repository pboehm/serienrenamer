#
# Class that extracts information about episodes
# from the serienjunkies.de-Page
#
require 'uri'
require 'mechanize'

module Plugin

    class SerienjunkiesDe < Serienrenamer::Pluginbase

        def self.plugin_name; "SerienjunkiesDe" end
        def self.plugin_url; "http://serienjunkies.de" end
        def self.usable; true end
        def self.priority; 50 end

        # this method will be called from the main program
        # with an Serienrenamer::Episode instance as parameter
        #
        # if this is the first call to this method, it builds up
        # a hash with all series and existing episodes, which can
        # be used by all future method calls
        #
        def self.generate_episode_information(episode)

            raise ArgumentError, "Serienrenamer::Episode instance needed" unless
                episode.is_a?(Serienrenamer::Episode)

            unless defined? @cached_data
                @cached_data = Hash.new
            end

            if ! @cached_data.has_key?(episode.series)

                if episode.series.match(/\w+/)

                    # determine link to series
                    seriespage_link = self.find_link_to_series_page(episode.series)

                    if seriespage_link
                        seriesdata = self.parse_seriespage(seriespage_link)

                        @cached_data[episode.series] = seriesdata
                    end
                end
            end

            matched_episodes = []

            # tries to find an episodename in cached_data
            # otherwise returns empty array
            begin
                series = @cached_data[episode.series]
                identifier = "S%.2dE%.2d" % [ episode.season, episode.episode ]
                episodename = series[identifier]

                if episodename.match(/\w+/)
                    matched_episodes.push(episodename)
                end
            rescue
            end

            return matched_episodes
        end

        # tries to find the link to the series page because there are
        # plenty of different writings of some series
        #   :seriesname:    -  name of the series
        #
        # TODO make this more intelligent so that it tries other forms
        # of the name
        #
        # returns a link to a seriejunkies.de-page or nil if no page was found
        def self.find_link_to_series_page(seriesname)
            raise ArgumentError, "seriesname expected" unless seriesname.match(/\w+/)

            self.build_agent unless defined? @agent

            url = URI.join(plugin_url, "serien/%s.html" % seriesname[0].downcase )

            @agent.get(url).search("a.slink").each do |series|
                if series.text.match(/#{seriesname}/i)
                    return URI.join( plugin_url, series[:href]).to_s
                end
            end

            return nil
        end

        # parses the supplied url and returns a hash with
        # episode information indexed by episode identifier
        #   :page_url:      -  url of the serienjunkies page
        #   :german:        -  extract only german titles if true
        def self.parse_seriespage(page_url, german=true)

            self.build_agent unless defined? @agent

            series = {}

            seriesdoc  = @agent.get(page_url)
            epidoc = @agent.click(seriesdoc.link_with(:text => /^Episoden$/i))

            epidoc.search('div#sjserie > div.topabstand > table.eplist tr').each do |episode|

                next unless episode.search("td.thh").empty? # skip headings

                firstchild = episode.search(":first-child")[0].text
                md = firstchild.match(/(?<season>\d+)x(?<episode>\d+)/)

                next unless md

                # extract and save these information
                identifier = "S%.2dE%.2d" % [ md[:season].to_i, md[:episode].to_i ]

                german = episode.search("a")[1]
                next unless german

                series[identifier] = german.text.strip
            end

            return series
        end

        # build up a mechanize instance
        def self.build_agent
            @agent = Mechanize.new
        end
    end
end
