require File.dirname(__FILE__) + '/test_helper.rb'
require 'serienrenamer/episode.rb'

class TestSerienrenamer < Test::Unit::TestCase

    @@valid_filenames = [
        'Chuck.S01E01.Dies.ist.ein.Test.German.Dubbed.avi',
        'chuck.512.hdtv-lol.avi',
        'chuck.1212.hdtv-lol.avi',
        'chuck.5x12.hdtv-lol.avi',
    ]

    def test_episode_name_detection
 
        @@valid_filenames.each { |file|
            assert_equal(true, Serienrenamer::Episode.is_episode?(file))
        }

        assert_equal(false, Serienrenamer::Episode.is_episode?('video.flv'))
    end
end
