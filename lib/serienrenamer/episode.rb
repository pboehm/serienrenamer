require 'find'

class Serienrenamer::Episode

    attr_reader :series, :season, :episode, :episodename, :extension
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

        unless File.exists?(episodepath) || Dir.exists?(episodepath)
            raise ArgumentError, "episodepath not existing"
        end
        
        basepath = File.basename(episodepath)

        if File.file?(episodepath)
            basepath = basepath.chomp(File.extname(basepath)) 
        end

        unless Serienrenamer::Episode.contains_episode_information?(basepath)
            raise ArgumentError, 'Not an episode'
        end

        # extract information from filename
        pattern = @@PATTERNS.select { |p| ! basepath.match(p).nil? }[0]
        raise ArgumentError, 'no suitable pattern found, no episode ?' unless pattern

        infos = pattern.match(basepath)
        raise ArgumentError, 'suitable pattern does not match the file' unless infos

        @series = Serienrenamer::Episode.clean_episode_data(infos[:series]).strip
        @episodename = Serienrenamer::Episode.clean_episode_data(infos[:episodename], true).strip
        @season = infos[:season].to_i
        @episode = infos[:episode].to_i
        
        ###
        # setting up special behaviour
        @episodename_needed=episodename_needed
        @extension=File.extname(episodepath).gsub('.','')
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

    ##################
    # static methods #
    ##################

    # cleans strings from things that can occur in
    # episode files like dots (.) and trash words
    def self.clean_episode_data(data, include_trashwords=false)
        data.gsub!(/\./, " ")
        
        if include_trashwords
            cleanwords = data.split(/ /).select do |w| 
                @@TRASH_WORDS.grep(/^#{w}$/).empty? 
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

