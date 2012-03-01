# coding: UTF-8
require 'find'
require 'fileutils'
require 'wlapi'

module Serienrenamer

    class Episode

        attr_reader :season, :episode, :episodename,
            :extension, :episodepath, :success, :source_directory
        attr_accessor :episodename_needed, :series

        # patterns for suitable episodes
        @@PATTERNS = [
            # S01E01
            /^(?<series>.*)S(?<season>\d+)E(?<episode>\d+)(?<episodename>.*)$/i,
            # 101; 1212
            /^(?<series>.*\D)(?<season>\d+)(?<episode>\d{2})(?<episodename>\W*.*)$/,
            # 1x1; 12x12
            /^(?<series>.*)(?<season>\d+)x(?<episode>\d+)(?<episodename>.*)$/,
        ]

        # allowed endings for episode files
        @@ENDINGS = %w( mpg mpeg avi mkv wmv mp4 mov flv 3gp )

        # trash words that are removed from the episodename
        @@TRASH_WORDS = %w(
            German Dubbed DVDRip HDTVRip XviD ITG TVR inspired HDRip
            AMBiTiOUS RSG SiGHT SATRip WS TVS RiP READ GERMAN dTV aTV
            iNTERNAL CRoW MSE c0nFuSed UTOPiA scum EXPiRED BDRiP HDTV
            iTunesHD 720p x264 h264 CRiSP euHD WEBRiP ZZGtv ARCHiV DD20
            Prim3time Nfo Repack SiMPTY BLURAYRiP BluRay DELiCiOUS Synced
            UNDELiCiOUS fBi CiD iTunesHDRip RedSeven OiNK idTV DL DD51
        )

        # Constructor for the Episode-Class, which takes an episode as
        # argument and extracts as much as information from the file
        # that it can.
        def initialize(episodepath, episodename_needed=true)

            raise ArgumentError, 'no episodepath provided' unless episodepath

            # make some checks on the given episode path
            unless File.exists?(episodepath) || Dir.exists?(episodepath)
                raise ArgumentError, "episodepath not existing"
            end

            unless Episode.determine_video_file(episodepath)
                raise ArgumentError, 'no videofile found'
            end

            @source_directory = nil

            # normalize information for dirs/files
            basepath = File.basename(episodepath)

            if File.file?(episodepath)
                basepath = basepath.chomp(File.extname(basepath))
            elsif File.directory?(episodepath)
                @source_directory = episodepath

                # if directory does not contain episode information
                # check for an text file with suitable information
                unless Episode.contains_episode_information?(basepath)
                    info = Plugin::Textfile.generate_episode_information(episodepath)[0]
                    basepath = info if info
                end
            end

            unless Episode.contains_episode_information?(basepath)
                raise ArgumentError, 'no episode information existing'
            end

            @episodepath = Episode.determine_video_file(episodepath)

            infos = Episode.extract_episode_information(basepath)
            raise ArgumentError, 'no suitable regex pattern matches' unless infos

            @series = Episode.clean_episode_data(infos[:series]).strip
            @episodename = Episode.clean_episode_data(
                infos[:episodename], true, true).strip
            @season = infos[:season].to_i
            @episode = infos[:episode].to_i

            # setting up special behaviour
            @episodename_needed=episodename_needed
            @extension=File.extname(@episodepath).gsub('.','')
            @success=false
        end

        # Returns the episode information into a format like
        # S0xE0x, depending on @episodename_needed it includes
        # the episodename
        def to_s
            if @episodename_needed
                return "S%.2dE%.2d - %s.%s" % [ @season, @episode, @episodename, @extension ]
            else
                return "S%.2dE%.2d.%s" % [ @season, @episode, @extension ]
            end
        end

        # this method makes it possible to set the episodename
        # afterwards
        #
        # options:
        #   :data
        #           string that contains epissodename information
        #   :need_cleanup
        #           if true than it will apply the standard regex
        #           to clean the string and extracts that with
        #           the standard patterns
        #           if false the string will applied without any
        #           checks or cleanup
        #   :extract_seriesname
        #           tries to extract the seriesname from data
        def add_episode_information(data, need_cleanup=true, extract_seriesname=false)
            return unless data

            if need_cleanup
                if Episode.contains_episode_information?(data)
                    infos = Episode.extract_episode_information(data)
                    if infos
                        data = infos[:episodename]

                        # try to extract seriesname if needed
                        if extract_seriesname and infos[:series].match(/\w+/)
                            seriesname = Episode.clean_episode_data(infos[:series])
                            @series = seriesname.strip
                        end
                    end
                end
                data = Episode.clean_episode_data(data, true, true).strip
            end
            @episodename = data
        end

        # renames the given episodefile into the new
        # clean format and sets the status on success
        #
        def rename(destination_dir=".")
            raise IOError, 'episode file not existing' unless File.file?(@episodepath)
            destination_file = File.join(destination_dir, self.to_s)

            begin
                File.rename(@episodepath, destination_file)

                if @source_directory
                    FileUtils.remove_dir(@source_directory)
                end

                @success = true
            rescue SystemCallError => e
                puts "Rename failed: #{e}"
            end
        end

        ##################
        # static methods #
        ##################

        # cleans strings from things that can occur in
        # episode files like dots (.) and trash words
        #
        # parameter:
        #   :data
        #       string that will be cleaned
        #   :include_trashwords
        #       remove Words like German or Dubbed from
        #       the string (Trashwords)
        #   :repair_umlauts
        #       try to repair broken umlauts if they occur
        #
        def self.clean_episode_data(data, include_trashwords=false, repair_umlauts=false)
            data.gsub!(/\./, " ")
            data.gsub!(/\_/, " ")
            data.gsub!(/\-/, " ")

            # if this feature is enabled than all trash words
            # are removed from the string. If two trashwords
            # occur than all trailing words will be removed.
            # if a word is removed and the next is not a trash
            # word than the removed word will be included
            if include_trashwords
                purge_count= 0
                last_purge = nil
                cleanwords = []

                for word in data.split(/ /) do
                    next unless word.match(/\w+/)

                    word = repair_umlauts(word) if repair_umlauts

                    # if word is in TRASH_WORDS
                    if ! @@TRASH_WORDS.grep(/^#{word}$/i).empty?
                        purge_count += 1
                        last_purge = word

                        break if purge_count == 2;
                    else
                        if purge_count == 1 && last_purge != nil
                            cleanwords.push(last_purge)
                            purge_count = 0
                        end
                        cleanwords.push(word)
                    end
                end
                data = cleanwords.join(" ")
            end

            return data
        end

        # This method tries to repair some german umlauts so that
        # the following occurs
        #
        # ae => ä ; ue => ü ; oe => ö ; Ae => Ä ; Ue => Ü ; Oe => Ö
        #
        # This method uses a webservice at:
        #   http://wortschatz.uni-leipzig.de/
        # which produces statistics about the german language and
        # e.g. frequency of words occuring in the german language
        #
        # this method convert all broken umlauts in the word and compares
        # the frequency of both version and uses the version which is more
        # common
        #
        # returns an repaired version of the word if necessary
        def self.repair_umlauts(word)

            if contains_eventual_broken_umlauts?(word)

                repaired = word.gsub(/ae/, 'ä').gsub(/ue/, 'ü').gsub(/oe/, 'ö')
                repaired.gsub!(/^Ae/, 'Ä')
                repaired.gsub!(/^Ue/, 'Ü')
                repaired.gsub!(/^Oe/, 'Ö')

                ws = WLAPI::API.new

                res_broken  = ws.frequencies(word)
                freq_broken = res_broken.nil? ? -1 : res_broken[0].to_i

                res_repaired  = ws.frequencies(repaired)
                freq_repaired = res_repaired.nil? ? -1 : res_repaired[0].to_i

                if freq_repaired > freq_broken
                    return repaired
                end
            end
            return word
        end

        # checks for eventual broken umlauts
        #
        # returns true if broken umlaut if included
        def self.contains_eventual_broken_umlauts?(string)
            ! string.match(/ae|ue|oe|Ae|Ue|Oe/).nil?
        end

        # tries to match the given string against
        # all supported regex-patterns and returns true if a
        # suitable regex is found
        def self.contains_episode_information?(info)
            @@PATTERNS.each do |p|
                if info.match(p)
                    return true
                end
            end
            return false
        end

        # tries to find a suitable pattern and returns
        # the matched data or nil if nothing matched
        def self.extract_episode_information(info)
            pattern = @@PATTERNS.select { |p| ! info.match(p).nil? }[0]
            if pattern
                return pattern.match(info)
            end

            return nil
        end

        # tries to find a valid video file in a given path.
        #
        # If path is a file it returns path unchanged if file
        # is a valid video file or nil unless
        #
        # If path is a dir it searches for the biggest valid
        # videofile in it and returns the path or nil if nothing
        # found
        def self.determine_video_file(path)
            if File.file?(path)
                matched_endings = @@ENDINGS.select { |e| ! path.match(/#{e}$/).nil? }
                return path if ! matched_endings.empty?

            elsif File.directory?(path)
                videofile = nil
                for file in Find.find(path) do
                    matched_endings = @@ENDINGS.select { |e| ! file.match(/#{e}$/).nil? }
                    if ! matched_endings.empty?
                        if videofile == nil || File.size(file) > File.size(videofile)
                            videofile = file
                        end
                    end
                end

                return videofile if videofile
            end

            return nil
        end
    end
end
