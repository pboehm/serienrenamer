# encoding: UTF-8
require 'media_wiki'

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
        @@EPISODE_ENTRY_PATTERN = /\{\{Episodenlisteneintrag|S-Episode/
        @@SERIES_SITE_TEST_PATTERN = /\{\{Infobox.Fernsehsendung.*\}\}/m
        @@DISAMBIGUATION_TEST_PATTERN = /\{\{Begriffsklärung\}\}/m
        @@CONTAINS_LINK_TO_EPISODE_LIST = /Hauptartikel.*(?<main>Liste.*?)[\]\}]+/
        @@CONTAINS_INARTICLE_EPISODE_LIST = /\<div.*\>Staffel.(\d+).*\<\/div\>.*class=\"wikitable\".*titel/m
        @@INPAGE_SEASON_SEPARATOR = /\<div.style=\"clear:both\;.class=\"NavFrame\"\>/
        @@WIKITABLE_EXTRACT_PATTERN = /(\{\|.class=\"wikitable\".*\|\})\n/m
        @@IS_ONE_LINE_EPISODE_LIST = /\|.*\|\|.*\|\|.*\|\|/m


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
                tries = 3
                search_pattern = episode.series
                search_pattern_modified = false

                begin
                    wiki.search(search_pattern, nil, 50).each do |title|
                        pagedata = wiki.get(title)
                        if is_series_main_page?(pagedata)
                            series_site = title
                            break
                        end
                    end

                    # modify the search term pattern so that it contains
                    # only the last word if the search_pattern contains
                    # more than one words
                    if series_site.nil? && ! search_pattern_modified
                        search_pattern = search_pattern.match(/(\w+)\s*$/)[1]
                        search_pattern_modified = true
                        raise EOFError if search_pattern # break out and retry
                    end
                rescue MediaWiki::APIError => e
                    tries -= 1
                    retry if tries > 0
                rescue EOFError => e
                    retry
                end

                return [] unless series_site

                # look for a link to a list of episodes
                pagedata = wiki.get(series_site)

                if contains_link_to_episode_list?(pagedata)
                    mainarticle = pagedata.match(@@CONTAINS_LINK_TO_EPISODE_LIST)[:main]
                    if mainarticle
                        episodelist_page = wiki.get(mainarticle)
                        series = parse_episodelist_page_data(episodelist_page)

                        @cached_data[episode.series] = series
                    end

                elsif contains_inarticle_episode_list?(pagedata)
                    series = parse_inarticle_episodelist_page_data(pagedata)
                    @cached_data[episode.series] = series

                else
                    warn "no episode list found"
                    return []
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
        # from a string that contains a wikipedia episodelist page
        #
        # returns an Array of Arrays with episode information
        # where episode and season numbers are the indizes
        def self.parse_episodelist_page_data(pagedata, debug=false)
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


        # This method will extract season based information
        # from a string that contains a series page with an
        # episodelist included
        #
        # returns an Array of Arrays with episode information
        # where episode and season numbers are the indizes
        def self.parse_inarticle_episodelist_page_data(pagedata, debug=false)
            raise ArgumentError, 'String with pagedata expected' unless
                pagedata.is_a?(String)

            series_data = []

            # look for a paragraph with an episodelist
            episodelist_paragraph = pagedata.split(/==.*==/).select { |p|
                contains_inarticle_episode_list?(p) }[0]

            raise ArgumentError, 'no episodelist found' unless episodelist_paragraph

            # iterate through all seasons in this episode table
            episodelist_paragraph.split(@@INPAGE_SEASON_SEPARATOR).each do |season|
                next unless contains_inarticle_episode_list?(season)

                season_nr = season.match(@@CONTAINS_INARTICLE_EPISODE_LIST)[1].to_i

                wikitable = season.match(@@WIKITABLE_EXTRACT_PATTERN)[1]

                # we have to detect the type of the inarticle season page
                # because there are two different kinds of table structures
                # used in the german wikipedia
                if self.is_episode_list_with_one_episode_per_line?(wikitable)
                    episodes = parse_inarticle_season_table_with_one_line(wikitable)
                else
                    episodes = parse_inarticle_season_table(wikitable)
                end

                # HACK if a season is splitted into different parts
                # eg. Flashpoint (2.1 and 2.2) than merge that if possible
                if series_data[season_nr] != nil
                    series_data[season_nr].each_with_index do |item, index|
                        episodes[index] = item unless episodes[index]
                    end
                end

                series_data[season_nr] = episodes
            end

            return series_data
        end


        # this method will be called with a wikitable for a season
        # as parameter and will extract all episodes from this
        # and returns that as an array where the episode number is
        # the index
        #
        # Example for an wikitable for episodes:
        #
        # {| class="wikitable" width="100%"
        # |- vertical-align: top; text-align:center; "
        # | width="15" | '''Nummer''' <br /><small>(Gesamt)<small>
        # | width="15" | '''Nummer''' <br /><small>(Staffel)<small>
        # ! width="250" | Originaltitel
        # ! width="250" | Deutscher Titel
        # ! width="180" | Erstausstrahlung<br /><small>(USA Network)</small>
        # ! width="180" | Erstausstrahlung<br /><small>(RTL)</small>
        # ! width="180" | Erstausstrahlung<br /><small>(SF zwei)</small>
        # |-
        # | bgcolor="#DFEEEF"| 01
        # | 01
        # | ''Pilot''
        # | ''Auch Reiche sind nur Menschen''
        # | 4. Mai 2009
        # | 17. Mai 2011
        # | 6. Juni 2011 (Teil 1)<br />13. Juni 2011 (Teil 2)
        # |-
        # |}
        #
        def self.parse_inarticle_season_table(table)
            raise ArgumentError, 'String with seasontable expected' unless
                table.is_a?(String)

            season_data = []
            episode_nr_line_nr   = nil
            episode_name_line_nr = nil

            table.split(/^\|\-.*$/).each do |tablerow|
                tablerow.strip!

                # skip invalid rows
                lines = tablerow.lines.to_a
                next unless lines.length >= 4

                if tablerow.match(/width=\"\d+\"/)
                    # extract line numbers for needed data that
                    # are in the table header
                    lines.each_with_index do |item, index|
                        if item.match(/Nummer.*Staffel/i)
                            episode_nr_line_nr = index

                        # TODO make the following more variable
                        elsif item.match(/Deutscher.*Titel/i)
                            episode_name_line_nr = index
                        end
                    end
                else
                    # extract episode information
                    if episode_nr_line_nr && episode_name_line_nr

                        md_nr = lines[episode_nr_line_nr].strip.match(/(\d+)/)
                        if md_nr
                            episode_nr = md_nr[1].to_i

                            md_name = lines[episode_name_line_nr].strip.match(/^\|.(.*)$/)
                            if md_name
                                episode_name = md_name[1]
                                episode_name.gsub!(/[\'\"\[\]]/, "")
                                next unless episode_name.match(/\w+/)

                                season_data[episode_nr] = episode_name.strip
                            end
                        end
                    end
                end
            end

            return season_data
        end


        # this method will be called with a wikitable for a season
        # as parameter and will extract all episodes from this
        # and returns that as an array where the episode number is
        # the index
        #
        # this method implements a special format that takes place in
        # e.g. 'Prison Break' where an episode is not spread along several
        # lines like in the method above
        #
        # Example for an wikitable for episodes:
        #
        #{| class="wikitable"
        # |- style="color:#black; background-color:#006699"
        # ! '''Episode''' !! '''Deutscher Titel''' !! '''Originaltitel''' !! '''Erstausstrahlung (DE)''' !! '''Erstausstrahlung (USA)'''
        # |-
        # |'''1''' (1-01) || Der große Plan || Pilot || 21. Juni 2007 || 29. August 2005
        # |-
        # |'''2''' (1-02) || Lügt Lincoln? || Allen || 21. Juni 2007 || 29. August 2005
        # |-
        # |'''3''' (1-03) || Vertrauenstest || Cell Test || 28. Juni 2007 || 5. September 2005
        # |-
        # |'''4''' (1-04) || Veronica steigt ein || Cute Poison || 28. Juni 2007 || 12. September 2005
        #
        def self.parse_inarticle_season_table_with_one_line(table)
            raise ArgumentError, 'String with seasontable expected' unless
                table.is_a?(String)

            season_data = []
            episode_nr_col   = nil
            episode_name_col = nil

            table.split(/^\|\-.*$/).each do |tablerow|

                if tablerow.match(/!!.*!!.*!!/)
                    # extract column numbers from table header
                    tablerow.split(/!!/).each_with_index do |col,index|
                        episode_nr_col   = index if col.match(/Episode/i)
                        episode_name_col = index if col.match(/Deutsch.*Titel/i)
                    end

                elsif tablerow.match(/\|\|.*\w+.*\|\|/)
                    tablerow.strip!
                    columns = tablerow.split(/\|\|/)

                    # the following cleanes up the column so that the following occurs
                    # " '''7''' (1-07) " => "7     1 07"
                    #
                    # we can now extract the last bunch of digits and this algorithm is
                    # some kind of format independent
                    dirty_episode_nr   = columns[episode_nr_col].gsub(/\D/, " ").strip
                    episode_nr = dirty_episode_nr.match(/(\d+)$/)[1]
                    next unless episode_nr

                    episode_name = columns[episode_name_col].strip
                    next unless episode_nr.match(/\w+/)

                    season_data[episode_nr.to_i] = episode_name
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

        # test if the page contains a episode list
        def self.contains_inarticle_episode_list?(page)
            page.match(@@CONTAINS_INARTICLE_EPISODE_LIST) != nil
        end

        # tests for the type of in article episode list
        def self.is_episode_list_with_one_episode_per_line?(page)
            page.match(@@IS_ONE_LINE_EPISODE_LIST) != nil
        end
    end
end
