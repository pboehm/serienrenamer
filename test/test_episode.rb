require File.dirname(__FILE__) + '/test_helper.rb'
require 'serienrenamer/episode.rb'

class TestEpisode < Test::Unit::TestCase

    @@valid_filenames = [
        'Chuck.S01E01.Dies.ist.ein.Test.German.Dubbed.avi',
        'chuck.512.hdtv-lol.avi',
        'chuck.1212.hdtv-lol.avi',
        'chuck.5x12.hdtv-lol.avi',
        '5x12.avi',
    ]

    def test_episode_name_detection
 
        @@valid_filenames.each { |file|
            assert_equal(true, Serienrenamer::Episode.is_episode?(file))
        }

        assert_equal(false, Serienrenamer::Episode.is_episode?('video.flv'))
    end

    def test_episode_information_extraction

        assert_raise(ArgumentError) { Serienrenamer::Episode.new('video.flv')}
       
        assert_equal('Chuck', Serienrenamer::Episode.new(@@valid_filenames[0]).series)
        assert_equal(1, Serienrenamer::Episode.new(@@valid_filenames[0]).season)
        assert_equal(1, Serienrenamer::Episode.new(@@valid_filenames[0]).episode)
    end
end
