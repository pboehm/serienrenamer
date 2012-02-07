require 'find'
require 'fileutils'

class Serienrenamer::Episode

    attr_reader :series, :season, :episode, :episodename,
        :extension, :episodepath, :success
    attr_accessor :episodename_needed

    # patterns for suitable episodes
    @@PATTERNS = [
        # S01E01
        /^(?<series>.*)S(?<season>\d+)E(?<episode>\d+)(?<episodename>.*)$/i,
        # 101; 1212
        /^(?<series>.*\D)(?<season>\d+)(?<episode>\d{2})(?<episodename>\D.*)$/,
        # 1x1; 12x12
        /^(?<series>.*)(?<season>\d+)x(?<episode>\d+)(?<episodename>.*)$/,
    ]

    # allowed endings for episode files
    @@ENDINGS = %w( mpg mpeg avi mkv wmv mp4 mov flv 3gp )

    # trash words that are removed from the episodename
    @@TRASH_WORDS = %w(
        German Dubbed DVDRip HDTVRip XviD ITG TVR inspired HDRip
        AMBiTiOUS RSG SiGHT SATRip WS TVS RiP READ GERMAN dTV aTV
        iNTERNAL CRoW MSE c0nFuSed UTOPiA scum EXPiRED BDRiP
        iTunesHD 720p x264 h264 CRiSP euHD WEBRiP ZZGtv ARCHiV
        Prim3time Nfo Repack SiMPTY BLURAYRiP BluRay DELiCiOUS
        UNDELiCiOUS fBi CiD iTunesHDRip RedSeven OiNK idTV
    )

    # Constructor for the Episode-Class, which takes an episode as
    # argument and extracts as much as information from the file
    # that it can.
    def initialize(episodepath, episodename_needed=true)

        # make some checks on the given episode path
        unless File.exists?(episodepath) || Dir.exists?(episodepath)
            raise ArgumentError, "episodepath not existing"
        end

        unless Serienrenamer::Episode.determine_video_file(episodepath)
            raise ArgumentError, 'no videofile found'
        end

        @source_directory = nil

        # normalize information for dirs/files
        basepath = File.basename(episodepath)

        if File.file?(episodepath)
            basepath = basepath.chomp(File.extname(basepath))
        elsif File.directory?(episodepath)
            @source_directory = episodepath
        end

        unless Serienrenamer::Episode.contains_episode_information?(basepath)
            raise ArgumentError, 'no episode information existing'
        end

        @episodepath = Serienrenamer::Episode.determine_video_file(episodepath)

        # extract information from basepath
        pattern = @@PATTERNS.select { |p| ! basepath.match(p).nil? }[0]
        raise ArgumentError, 'no suitable pattern found, no episode ?' unless pattern

        infos = pattern.match(basepath)
        raise ArgumentError, 'suitable pattern does not match the file' unless infos

        @series = Serienrenamer::Episode.clean_episode_data(infos[:series]).strip
        @episodename = Serienrenamer::Episode.clean_episode_data(
            infos[:episodename], true).strip
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

    # renames the given episodefile into the new
    # clean format and sets the status on success
    def rename(destination_dir=".")
        raise IOError, 'episode file not existing' unless File.file?(@episodepath)
        destination_file = File.join(destination_dir, self.to_s)
        raise IOError, 'destination file already existing' if File.file?(destination_file)

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
    def self.clean_episode_data(data, include_trashwords=false)
        data.gsub!(/\./, " ")

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

                if @@TRASH_WORDS.include?(word)
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

    # tries to match the given string against
    # all supported regex-patterns and returns true if a
    # suitable regex is found
    def self.contains_episode_information?(info)
        @@PATTERNS.each do |p|
            if info.match(p) != nil
                return true
            end
        end
        return false
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

