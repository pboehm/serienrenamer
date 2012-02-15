# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'
require 'media_wiki'

class TestPluginWikipedia < Test::Unit::TestCase
    @@valid_filenames = {
        'flpo'   => 'test/testfiles/Flashpoint.S04E04.German.Dubbed.WEB-DL.XViD.avi',
        'two'    => 'test/testfiles/Two.and.a.half.Men.S09E07.German.Dubbed.WS.WEB-DL.XviD-GDR.avi',
    }

    @@valid_directories = {
        'chuck'  => 'test/testfiles/Chuck.S01E01.German.Dubbed.BLURAYRiP.WEB-DL',
        'chuck2'  => 'test/testfiles/Chuck.S02E10.German.Dubbed.BLURAYRiP.WEB-DL',
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

    def test_page_data_extraction
        wiki = MediaWiki::Gateway.new('http://de.wikipedia.org/w/api.php')

        data = wiki.get("Liste der Episoden von Bones – Die Knochenjägerin")
        seasons = Plugin::Wikipedia.parse_page_data(data)

        assert_equal("Die Frau im Teich", seasons[1][1])
        assert_equal("Ein Verräter im Feuer", seasons[2][11])
        assert_equal("Vom Vergehen und Werden", seasons[6][23])

        data = wiki.get("Liste der Criminal-Minds-Episoden")
        seasons = Plugin::Wikipedia.parse_page_data(data)

        assert_equal("Der Abgrund", seasons[1][1])
        assert_equal("Rivalen", seasons[2][9])
        assert_equal("Valhalla", seasons[6][17])

        data = wiki.get("Liste der Dexter-Episoden")
        seasons = Plugin::Wikipedia.parse_page_data(data)

        assert_equal("Rot wie Blut", seasons[1][10])
        assert_equal("Hitzewelle", seasons[2][4])
        assert_equal("Familienväter", seasons[4][6])

        data = wiki.get("Liste der Simpsons-Episoden")
        seasons = Plugin::Wikipedia.parse_page_data(data, true)

        assert_equal("Es weihnachtet schwer", seasons[1][1])
        assert_equal("G.I. Homer", seasons[18][5])
        assert_equal("Die Farbe Gelb", seasons[21][13])

        data = wiki.get("Liste der Misfits-Episoden")
        seasons = Plugin::Wikipedia.parse_page_data(data)

        assert_equal("Das Gewitter", seasons[1][1])
        assert_equal("Nathan wird Vater", seasons[2][7])
    end

    def test_episode_information_generation

        #flpo = Serienrenamer::Episode.new(@@valid_filenames['flpo'])
        #data = Plugin::Wikipedia.generate_episode_information(flpo)[0]
        #assert_equal("S04E04 - Getrübte Erinnerungen.avi", flpo.to_s)

        two = Serienrenamer::Episode.new(@@valid_filenames['two'])
        data = Plugin::Wikipedia.generate_episode_information(two)[0]
        two.add_episodename(data, false) if data
        assert_equal("S09E07 - Das Tagebuch.avi", two.to_s)

        chuck = Serienrenamer::Episode.new(@@valid_directories['chuck'])
        data = Plugin::Wikipedia.generate_episode_information(chuck)[0]
        chuck.add_episodename(data, false) if data
        assert_equal("S01E01 - Pilot.avi", chuck.to_s)

        chuck2 = Serienrenamer::Episode.new(@@valid_directories['chuck2'])
        data = Plugin::Wikipedia.generate_episode_information(chuck2)[0]
        chuck2.add_episodename(data, false) if data
        assert_equal("S02E10 - Chuck gegen zehn Millionen.avi", chuck2.to_s)
    end

    def test_check_for_series_main_page

        wiki = MediaWiki::Gateway.new('http://de.wikipedia.org/w/api.php')

        assert_equal(false, Plugin::Wikipedia.is_series_main_page?(wiki.get("Bones")))
        assert_equal(true,  Plugin::Wikipedia.is_series_main_page?(wiki.get("Bones – Die Knochenjägerin")))
        assert_equal(false, Plugin::Wikipedia.is_series_main_page?(wiki.get("Bones – Der Tod ist erst der Anfang")))
        assert_equal(false, Plugin::Wikipedia.is_series_main_page?(wiki.get("Chuck")))
        assert_equal(true,  Plugin::Wikipedia.is_series_main_page?(wiki.get("Chuck (Fernsehserie)")))
        assert_equal(false, Plugin::Wikipedia.is_series_main_page?(wiki.get("Chuck (Album)")))

    end

    def test_check_for_disambiguation_page

        wiki = MediaWiki::Gateway.new('http://de.wikipedia.org/w/api.php')

        assert_equal(true,  Plugin::Wikipedia.is_disambiguation_site?(wiki.get("Bones")))
        assert_equal(false, Plugin::Wikipedia.is_disambiguation_site?(wiki.get("Bones – Die Knochenjägerin")))
        assert_equal(true,  Plugin::Wikipedia.is_disambiguation_site?(wiki.get("Chuck")))
        assert_equal(false, Plugin::Wikipedia.is_disambiguation_site?(wiki.get("Chuck (Fernsehserie)")))
        assert_equal(false, Plugin::Wikipedia.is_disambiguation_site?(wiki.get("Chuck (Album)")))

    end

end
