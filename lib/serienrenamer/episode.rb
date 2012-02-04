class Serienrenamer::Episode

    attr_reader :series, :season, :episode, :episodename

    # patterns for suitable episodes  
    @@patterns = [
        # S01E01 ....
        /^(?<series>.*)S(?<season>\d+)E(?<episode>\d+)(?<episodename>.*)$/i, 
        # 101  => S01E01;  1212 => S12E12
        /^(?<series>.*\D)(?<season>\d+)(?<episode>\d{2})(?<episodename>\D.*)$/, 
        # 1x1 => S01E01; 12x12 => S12E12
        /^(?<series>.*)(?<season>\d+)x(?<episode>\d+)(?<episodename>.*)$/, 
    ]
    
    # create a episode if it could be 
    # an episode
    def initialize(episodepath)
        unless Serienrenamer::Episode.is_episode?(episodepath) then
            raise ArgumentError, 'Not an episode'
        end

        # extract information from filename
        pattern = @@patterns.select { |p| ! episodepath.match(p).nil? }[0]
        raise ArgumentError, 'no suitable pattern found, no episode ?' unless pattern

        infos = pattern.match(episodepath)
        @series = Serienrenamer::Episode.clean_filename_info(infos[:series]).strip
        @episodename = Serienrenamer::Episode.clean_filename_info(infos[:episodename]).strip
        @season = infos[:season].to_i
        @episode = infos[:episode].to_i

    end

    def to_s
        puts "S%.2dE%.2d - %s" % [ @season, @episode, @episodename ]
    end

    ###
    # static methods
    def self.clean_filename_info(s)
        s.gsub(/\./, " ")
    end

    def self.is_episode?(episodefile)
        @@patterns.each do |p| 
            if episodefile.match(p) != nil then
                return true
            end
        end
        return false
    end
end

