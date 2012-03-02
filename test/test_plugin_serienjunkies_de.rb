# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'

class TestPluginSerienjunkiesDe < Test::Unit::TestCase
    @@valid_filenames = {
        'flpo'   => 'test/testfiles/Flashpoint.S04E04.German.Dubbed.WEB-DL.XViD.avi',
        'dani'   => 'test/testfiles/Dr.Dani.Santino.S01E04.German.Dubbed.WEB-DL.XViD.avi',
        'two'    => 'test/testfiles/Two.and.a.half.Men.S09E07.German.Dubbed.WS.WEB-DL.XviD-GDR.avi',
        'simp'   => 'test/testfiles/Die.Simpsons.S09E07.German.Dubbed.WS.WEB-DL.XviD-GDR.avi',
        'sea'    => 'test/testfiles/tcpa-seapatrol_s05e11.avi',
    }

    @@valid_directories = {
        'chuck'  => 'test/testfiles/Chuck.S01E01.German.Dubbed.BLURAYRiP.WEB-DL',
        'chuck2' => 'test/testfiles/Chuck.S02E10.German.Dubbed.BLURAYRiP.WEB-DL',
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

    def test_seriespage_url_search

        plugin = Plugin::SerienjunkiesDe

        misfits = plugin.find_link_to_series_page("Misfits")
        assert_equal("http://serienjunkies.de/misfits/", misfits)

        thementalist = plugin.find_link_to_series_page("The Mentalist")
        assert_equal("http://serienjunkies.de/the-mentalist/", thementalist)

        ncis = plugin.find_link_to_series_page("NCIS")
        assert_equal("http://serienjunkies.de/ncis/", ncis)

        berger = plugin.find_link_to_series_page("The Hard Times Of RJ Berger")
        assert_equal(nil, berger)

    end

    def test_parse_seriespage

        plugin = Plugin::SerienjunkiesDe

        seasons = plugin.parse_seriespage("http://www.serienjunkies.de/royal-pains/")
        assert_match(/Auch.Reiche.sind.nur.Menschen/, seasons['S01E01'])
        assert_match(/Krank.vor.Liebe/, seasons['S02E02'])

        seasons = plugin.parse_seriespage("http://www.serienjunkies.de/flashpoint/")
        assert_match(/Zu.viele.Verlierer/, seasons['S02E02'])
        assert_match(/Der.Aufstand/, seasons['S02E16'])

        seasons = plugin.parse_seriespage("http://www.serienjunkies.de/necessary-roughness/")
        assert_match(/Touchdown/, seasons['S01E01'])
        assert_match(/Extremsport/, seasons['S01E06'])

        seasons = plugin.parse_seriespage("http://www.serienjunkies.de/Weeds/")
        assert_match(/Das.Geld.im.Pool/, seasons['S03E02'])
        assert_match(/Schlangennest/, seasons['S02E01'])
    end

    def test_episode_information_generation

        plugin = Plugin::SerienjunkiesDe

        flpo = Serienrenamer::Episode.new(@@valid_filenames['flpo'])
        data = plugin.generate_episode_information(flpo)[0]
        flpo.add_episode_information(data, true) if data
        assert_equal("S04E04 - Getrübte Erinnerungen.avi", flpo.to_s)

        two = Serienrenamer::Episode.new(@@valid_filenames['two'])
        data = plugin.generate_episode_information(two)[0]
        two.add_episode_information(data, true) if data
        assert_equal("S09E07 - Das Tagebuch.avi", two.to_s)

        chuck = Serienrenamer::Episode.new(@@valid_directories['chuck'])
        data = plugin.generate_episode_information(chuck)[0]
        chuck.add_episode_information(data, true) if data
        assert_equal("S01E01 - Pilot.avi", chuck.to_s)

        chuck2 = Serienrenamer::Episode.new(@@valid_directories['chuck2'])
        data = plugin.generate_episode_information(chuck2)[0]
        chuck2.add_episode_information(data, true) if data
        assert_equal("S02E10 - Chuck gegen zehn Millionen.avi", chuck2.to_s)

    end
end
