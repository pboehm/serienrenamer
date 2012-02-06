# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'
require 'serienrenamer/episode.rb'
require 'fileutils'

class TestEpisode < Test::Unit::TestCase

    @@valid_filenames = [
        'test/testfiles/Chuck.S01E01.Dies.ist.ein.Test.German.Dubbed.BLURAYRiP.DELiCiOUS.WEBRiP.CiD.avi',
        'test/testfiles/chuck.512.hdtv-lol.avi',
        'test/testfiles/chuck.1212.hdtv-lol.avi',
        'test/testfiles/chuck.5x12.hdtv-lol.avi',
        'test/testfiles/5x12.avi',
    ]

    def setup
        @@valid_filenames.each { |f|
            FileUtils.touch f unless File.file?(f)
        }
    end

    def test_episode_name_detection
 
        @@valid_filenames.each { |file|
            assert_equal(true, 
                Serienrenamer::Episode.contains_episode_information?(file))
        }

        assert_equal(false,
                Serienrenamer::Episode.contains_episode_information?('video.flv'))
    end

    def test_episode_information_extraction

        assert_raise(ArgumentError) { Serienrenamer::Episode.new('video.flv')}
        
        epi = Serienrenamer::Episode.new(@@valid_filenames[0]) 
        assert_equal('Chuck',epi.series)
        assert_equal(1, epi.season)
        assert_equal(1, epi.episode)
        assert_equal("Dies ist ein Test", epi.episodename)
        assert_equal("S01E01 - Dies ist ein Test.avi", epi.to_s)
    end

    def test_videofile_determination
        @@valid_filenames.each { |f| 
            assert_not_nil(Serienrenamer::Episode.determine_video_file(f))
        }    
    end
end
