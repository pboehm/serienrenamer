# encoding: UTF-8
module Plugin

    # This Plugin tries to extract the series
    # information from wikipedia
    #
    # (by now only the german wikipedia)
    class Wikipedia < Serienrenamer::Pluginbase

        def self.plugin_name; "Wikipedia" end
        def self.usable; true end
        def self.priority; 5 end

        @@WIKIPEDIA_URL = 'http://de.wikipedia.org/w/api.php'

        # patterns used in this class
        @@EPISODE_TABLE_PATTERN = /.*(?<table>\{\{Episodenlistentabelle.*\}\})\s*$/m
        @@EPISODE_ENTRY_PATTERN = /\{\{Episodenlisteneintrag/
        @@SERIES_SITE_TEST_PATTERN = /\{\{Infobox.Fernsehsendung.*\}\}/m
        @@DISAMBIGUATION_TEST_PATTERN = /\{\{Begriffsklärung\}\}/m
        @@CONTAINS_LINK_TO_EPISODE_LIST = /\{\{Hauptartikel\|(?<main>Liste.*)\}\}/

        # this method will be called from the main program
        # with an Serienrenamer::Episode instance as parameter
        #
        # it returns an array of episode information
        def self.generate_episode_information(episode)

            raise ArgumentError, "Serienrenamer::Episode instance needed" unless
                episode.is_a?(Serienrenamer::Episode)

            return [] unless episode.series.match(/\w+/)

            unless defined? @cached_data
                @cached_data = Hash.new
            end

            wiki = MediaWiki::Gateway.new(@@WIKIPEDIA_URL)

            if ! @cached_data.has_key?(episode.series)
                # search for a series site in wikipedia
                series_site = nil
                wiki.search(episode.series, nil, 50).each do |title|
                    pagedata = wiki.get(title)
                    if is_series_main_page?(pagedata)
                        series_site = title
                        break
                    end
                end

                return [] unless series_site

                # look for a link to a list of episodes
                pagedata = wiki.get(series_site)

                if contains_link_to_episode_list?(pagedata)
                    mainarticle = pagedata.match(@@CONTAINS_LINK_TO_EPISODE_LIST)[:main]
                    if mainarticle
                        episodelist_page = wiki.get(mainarticle)
                        series = parse_page_data(episodelist_page)
                        @cached_data[episode.series] = series
                    end
                else
                    raise RuntimeError, "In article episodelists not yet implemented"
                end
            end

            episode_names = []

            # tries to find an episodename in cached_data
            # otherwise returns empty array
            begin
                series = @cached_data[episode.series]
                episodename = series[episode.season][episode.episode]
                if episodename.match(/\w+/)
                    episode_names.push(episodename)
                end
            rescue
            end

            return episode_names
        end

        # This method will extract season based information
        # from a string that contains the MediaWiki pagedata
        #
        # returns an Array of Arrays with episode information
        # where episode and season numbers are the indizes
        def self.parse_page_data(pagedata, debug=false)
            raise ArgumentError, 'String with pagedata expected' unless
                pagedata.is_a?(String)

            series_data = []
            is_season_table_following = false
            season_number = nil

            # split the wikipedia page by headings and process
            # the following paragraph if the heading starts with
            # 'Staffel'
            pagedata.split(/(==.*)==/).each do |paragraph|
                if paragraph.match(/^==.*Staffel/)
                    match = paragraph.match(/^==.*Staffel.(?<seasonnr>\d+)/)
                    if match
                        season_number = match[:seasonnr].to_i
                        is_season_table_following = true
                    end
                elsif is_season_table_following
                    #
                    # extract season table from this paragraph
                    season = parse_season_table(paragraph)

                    series_data[season_number] = season
                    is_season_table_following = false
                end
            end

            return series_data
        end

        # this method will be called with a wikipedia seasontable
        # as parameter and will extract all episodes from this
        # and returns that as an array where the episode number is
        # the index
        def self.parse_season_table(table)
            raise ArgumentError, 'String with seasontable expected' unless
                table.is_a?(String)

            season_data = []

            matched_table = table.match(@@EPISODE_TABLE_PATTERN)
            if matched_table

                # extract all episode entries that
                # looks like the following
                #
                # {{Episodenlisteneintrag
                # | NR_GES = 107
                # | NR_ST = 1
                # | OT = The Mastodon in the Room
                # | DT = Die Rückkehr der Scheuklappen
                # | ZF =
                # | EA = {{dts|23|09|2010}}
                # | EAD = {{dts|08|09|2011}}
                # }}

                episodes = matched_table[:table].split(@@EPISODE_ENTRY_PATTERN)
                if episodes
                    episodes.each do |epi|

                        # build up a hash from the entry
                        infos = {}
                        epi.lines.each do |part|
                            parts = part.strip.match(/(?<key>\w+).=.(?<value>.*)$/)
                            if parts
                                infos[parts[:key].strip] = parts[:value].strip
                            end
                        end

                        next unless infos.has_key?('NR_ST')

                        # extract useful information and
                        # add it to the array
                        epi_nr = infos['NR_ST'].to_i
                        next unless epi_nr

                        # TODO make the following variable
                        epi_name = infos['DT'].strip

                        # remove all html tags and all following
                        # text from the episode name and the bold
                        # syntax from mediawiki [[text]]
                        epi_name.gsub!(/<\/?[^>]*>.*/, "")
                        epi_name.gsub!(/[\[\[\]\]]/, "")
                        next unless epi_name.match(/\w+/)

                        season_data[epi_nr] = epi_name
                    end
                end
            end
            return season_data
        end

        # this method checks if the page is the main page
        # for a series
        #
        # returns true if page contains the infobox that
        # is typical for series pages in wikipedia
        def self.is_series_main_page?(page)
            page.match(@@SERIES_SITE_TEST_PATTERN) != nil
        end

        # check the site if it is a disambiguation site
        #
        # returns true if this site links to pages with
        # themes with the same name
        def self.is_disambiguation_site?(page)
            page.match(@@DISAMBIGUATION_TEST_PATTERN) != nil
        end

        # test if the page contains a link to an article
        # with an episode list
        def self.contains_link_to_episode_list?(page)
            page.match(@@CONTAINS_LINK_TO_EPISODE_LIST) != nil
        end
    end
end
