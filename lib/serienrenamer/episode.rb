class Serienrenamer::Episode

    # patterns for suitable episodes  
    @@patterns = [
        /^(?<series>.*)S(?<season>\d+)E(?<episode>\d+)(?<episodename>.*)$/i, 
        /^(?<series>.*)(?<season>\d{1,2})(?<episode>\d{2})(?<episodename>.*)$/, 
        /^(?<series>.*)(?<season>\d+)x(?<episode>\d+)(?<episodename>.*)$/, 
    ]
    
    # create a episode if it could be 
    # an episode
    def initialize(episodepath)
        @episodepath = episodepath 
    end

    def split_episode_parts
        #parts = @suitable_pattern.match(@episodepath)
        #puts "S%.2dE%.2d - %s" % [ parts[:season], parts[:episode], parts[:episodename] ]
    end

    ###
    # static methods
    def self.is_episode?(episodefile)
        @@patterns.each do |p| 
            if episodefile.match(p) != nil then
                return true
            end
        end
        return false
    end
end

