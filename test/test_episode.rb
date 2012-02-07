# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'
require 'serienrenamer/episode.rb'
require 'fileutils'

class TestEpisode < Test::Unit::TestCase

    @@valid_filenames = {
        'chuckfull' => 'test/testfiles/Chuck.S01E01.Dies.ist.ein.Test.German.Dubbed.BLURAYRiP.DELiCiOUS.WEBRiP.CiD.avi',
        'chuck1' => 'test/testfiles/chuck.512.hdtv-lol.avi',
        'chuck2' => 'test/testfiles/chuck.1212.hdtv-lol.avi',
        'chuck3' => 'test/testfiles/chuck.5x12.hdtv-lol.avi',
        'without'=> 'test/testfiles/5x12.avi',
        'flpo'   => 'test/testfiles/Flashpoint.S04E04.Getruebte.Erinnerungen.German.Dubbed.WEB-DL.XViD.avi',
        'csiny'  => 'test/testfiles/sof-csi.ny.s07e20.avi',
        'legaltrash' =>'test/testfiles/flpo.404.Die.German.Erinnerungen.German.Dubbed.WEB-DL.XViD.avi',
    }

    def setup
        system('rm -r test/testfiles/*')

        @@valid_filenames.each { |n,f|
            FileUtils.touch f unless File.file?(f)
        }
    end

    def test_episode_name_detection

        @@valid_filenames.each { |name,file|
            assert_equal(true,
                Serienrenamer::Episode.contains_episode_information?(file))
        }

        assert_equal(false,
                Serienrenamer::Episode.contains_episode_information?('video.flv'))
    end

    def test_episode_information_extraction

        assert_raise(ArgumentError) { Serienrenamer::Episode.new('video.flv')}

        epi = Serienrenamer::Episode.new(@@valid_filenames["chuckfull"])
        assert_equal('Chuck',epi.series)
        assert_equal(1, epi.season)
        assert_equal(1, epi.episode)
        assert_equal("Dies ist ein Test", epi.episodename)
        assert_equal("S01E01 - Dies ist ein Test.avi", epi.to_s)

        flpo = Serienrenamer::Episode.new(@@valid_filenames["flpo"])
        assert_equal("S04E04 - Getruebte Erinnerungen.avi", flpo.to_s)

        csiny = Serienrenamer::Episode.new(@@valid_filenames["csiny"])
        csiny.episodename_needed=false
        assert_equal("S07E20.avi", csiny.to_s)

        legaltrash = Serienrenamer::Episode.new(@@valid_filenames["legaltrash"])
        assert_equal("S04E04 - Die German Erinnerungen.avi", legaltrash.to_s)
    end

    def test_videofile_determination
        @@valid_filenames.each { |n,f|
            assert_not_nil(Serienrenamer::Episode.determine_video_file(f))
        }
    end

    def test_episode_rename
        epi = Serienrenamer::Episode.new(@@valid_filenames["chuckfull"])
        epi.rename('test/testfiles/')
        assert_equal(true, epi.success)
    end
end
