# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'

class TestPluginSerienjunkiesFeed < Test::Unit::TestCase
    @@valid_filenames = {
        'chuck' => 'test/testfiles/chuck.312.hdtv-lol.avi',
        'flpo'   => 'test/testfiles/Flashpoint.S04E04.German.Dubbed.WEB-DL.XViD.avi',
        'csiny'  => 'test/testfiles/sof-csi.ny.s07e20.avi',
        'simps'  => 'test/testfiles/simpsons.s22e16.avi',
        'biglove'=> 'test/testfiles/idtv-big.love.s05e06.avi',
        'crmi'   => 'test/testfiles/crmi-s06e22.avi',
        'two'    => 'test/testfiles/Two.and.a.half.Men.S09E07.German.Dubbed.WS.WEB-DL.XviD-GDR.avi',
    }

    @@valid_directories = {
        'chuck'  => 'test/testfiles/Chuck.S01E01.German.Dubbed.BLURAYRiP.WEB-DL',
    }

    def setup
        system('rm -r test/testfiles/*')

        @@valid_filenames.each { |n,f|
            FileUtils.touch f unless File.file?(f)
        }

        @@valid_directories.each { |n,d|
            FileUtils.mkdir(d)
            FileUtils.touch(File.join(d, 'episode.avi'))
        }
    end

    # improve this so that the Plugin uses a local xml file
    def skip_test_information_extraction
        simps = Serienrenamer::Episode.new(@@valid_filenames['simps'])
        data = Plugin::SerienjunkiesOrgFeed.generate_episode_information(simps)[0]
        simps.add_episode_information(data, true)
        assert_equal("S22E16 - Ein Sommernachtstrip.avi", simps.to_s)

        flpo = Serienrenamer::Episode.new(@@valid_filenames['flpo'])
        data = Plugin::SerienjunkiesOrgFeed.generate_episode_information(flpo)[0]
        flpo.add_episode_information(data, true)
        assert_equal("S04E04 - Getruebte Erinnerungen.avi", flpo.to_s)

        big = Serienrenamer::Episode.new(@@valid_filenames['biglove'])
        data = Plugin::SerienjunkiesOrgFeed.generate_episode_information(big)[0]
        big.add_episode_information(data, true)
        assert_equal("S05E06 - Scheidung.avi", big.to_s)

        crmi = Serienrenamer::Episode.new(@@valid_filenames['crmi'])
        data = Plugin::SerienjunkiesOrgFeed.generate_episode_information(crmi)[0]
        crmi.add_episode_information(data, true)
        assert_equal("S06E22 - Die Dunkelkammer Moerder.avi", crmi.to_s)

        two = Serienrenamer::Episode.new(@@valid_filenames['two'])
        data = Plugin::SerienjunkiesOrgFeed.generate_episode_information(two)[0]
        two.add_episode_information(data, true)
        assert_equal("S09E07 - Das Tagebuch.avi", two.to_s)
    end
end
