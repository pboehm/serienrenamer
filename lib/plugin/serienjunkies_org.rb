#
# Class that extracts information about episodes
# from the serienjunkies.org-Page
#
require 'uri'
require 'mechanize'
require 'yaml'

module Plugin

  class SerienjunkiesOrg < Serienrenamer::Pluginbase

    def self.plugin_name; "SerienjunkiesOrg" end
    def self.plugin_url; "http://serienjunkies.org" end
    def self.usable; true end
    def self.priority; 10 end

    # Public: tries to search for an appropriate episodename
    #
    # if this is the first call to this method, it builds up
    # a hash with all series and existing episodes, which can
    # be used by all future method calls
    #
    # episode - Serienrenamer::Episode instance which holds the information
    #
    # Returns an array of possible episodenames
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

        identifier = "%d_%d" % [ episode.season, episode.episode ]
        episodename = series[identifier]

        if episodename.match(/\w+/)
          matched_episodes.push(episodename)
        end
      rescue
      end

      return matched_episodes
    end

    # Public: tries to find a link to the seriespage
    #
    # seriesname  - the series name for which the page is searched
    #
    # Returns the link or nil
    def self.find_link_to_series_page(seriesname)
      raise ArgumentError, "seriesname expected" unless seriesname.match(/\w+/)

      self.build_agent unless defined? @agent

      url = URI.join(plugin_url, "?cat=0&l=%s" % seriesname[0].downcase )

      pattern = seriesname.gsub(/\s/, ".*")

      @agent.get(url).search("div#sidebar > ul > li > a").each do |series|
        if series.text.match(/#{pattern}/i)
          return URI.join( plugin_url, series[:href]).to_s
        end
      end

      nil
    end

    # Public: parses a series page and extracts the episode information
    #
    # page_url   - the url to the seriespage
    # german     - if true it extracts only german data (Defaults to true)
    #
    # Returns a hash which contains the episode information or an empty
    # hash if there aren't any episodes
    def self.parse_seriespage(page_url, german=true, debug=false)

      self.build_agent unless defined? @agent

      series = {}
      doc = @agent.get(page_url)

      doc.search('div#sidebar > div#scb > div.bkname > a').each do |link|
        if german
          next unless link.content.match(/Staffel/i)
        else
          next unless link.content.match(/Season/i)
        end

        site = @agent.get(link[:href])
        episodes = self.parse_season_subpage(site, german)

        series.merge!(episodes)
      end

      puts series.to_yaml if debug

      return series
    end

    # Public: extracts the episodes from one season
    #
    # page   - Mechanize page object which holds the season
    # german - extracts german or international episodes
    #
    # Returns a hash with all episodes (unique)
    def self.parse_season_subpage(page, german=true)

      episodes = {}

      page.search('div.post > div.post-content strong:nth-child(1)').each do |e|

        content =  e.content
        md = Serienrenamer::Episode.extract_episode_information(content)
        next unless md

        if german
          next unless content.match(/German/i)
          next if content.match(/Subbed/i)
        else
          next if content.match(/German/i)
        end

        episodename =
          Serienrenamer::Episode.clean_episode_data(md[:episodename], true)
        next unless episodename && episodename.match(/\w+/)

        id = "%d_%d" % [ md[:season].to_i, md[:episode].to_i ]

        next if episodes[id] && episodes[id].size > episodename.size

        episodes[id] = episodename

      end

      return episodes
    end

    private

    # Private: constructs a Mechanize instance and adds a fix that interprets
    #          every response as html
    #
    # Returns the agent
    def self.build_agent
      @agent = Mechanize.new do |a|
        a.post_connect_hooks << lambda do |_,_,response,_|
          if response.content_type.nil? || response.content_type.empty?
            response.content_type = 'text/html'
          end
        end
      end
    end
  end
end
