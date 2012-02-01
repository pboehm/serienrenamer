$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Serienrenamer
    VERSION = '0.0.1'

    class Episode

        # patterns for suitable episodes  
        @@patterns = [/S\d+E\d+/i, /\D+\d{3}\D+/]
        
        # create a episode if it could be 
        # an episode
        def initialize(episodepath)
            @episodepath = episodepath 
        end

        def is_episode?

            @@patterns.each do |p| 
                if !@episodepath.match(p).nil?
                    @suitable_pattern = p
                    return true
                end
            end

            return false
        end
    end

end
