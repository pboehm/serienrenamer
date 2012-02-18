# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'
require 'media_wiki'

class TestPluginWikipedia < Test::Unit::TestCase
    @@valid_filenames = {
        'flpo'   => 'test/testfiles/Flashpoint.S04E04.German.Dubbed.WEB-DL.XViD.avi',
        'dani'   => 'test/testfiles/Dr.Dani.Santino.S01E04.German.Dubbed.WEB-DL.XViD.avi',
        'two'    => 'test/testfiles/Two.and.a.half.Men.S09E07.German.Dubbed.WS.WEB-DL.XviD-GDR.avi',
        'simp'   => 'test/testfiles/Die.Simpsons.S09E07.German.Dubbed.WS.WEB-DL.XviD-GDR.avi',
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

    def test_episode_list_page_data_extraction
        wiki = MediaWiki::Gateway.new('http://de.wikipedia.org/w/api.php')

        data = wiki.get("Liste der Episoden von Bones – Die Knochenjägerin")
        seasons = Plugin::Wikipedia.parse_episodelist_page_data(data)

        assert_equal("Die Frau im Teich", seasons[1][1])
        assert_equal("Ein Verräter im Feuer", seasons[2][11])
        assert_equal("Vom Vergehen und Werden", seasons[6][23])

        data = wiki.get("Liste der Criminal-Minds-Episoden")
        seasons = Plugin::Wikipedia.parse_episodelist_page_data(data)

        assert_equal("Der Abgrund", seasons[1][1])
        assert_equal("Rivalen", seasons[2][9])
        assert_equal("Valhalla", seasons[6][17])

        data = wiki.get("Liste der Dexter-Episoden")
        seasons = Plugin::Wikipedia.parse_episodelist_page_data(data)

        assert_equal("Rot wie Blut", seasons[1][10])
        assert_equal("Hitzewelle", seasons[2][4])
        assert_equal("Familienväter", seasons[4][6])

        data = wiki.get("Liste der Simpsons-Episoden")
        seasons = Plugin::Wikipedia.parse_episodelist_page_data(data, true)

        assert_equal("Es weihnachtet schwer", seasons[1][1])
        assert_equal("Bösartige Spiele", seasons[4][5])
        assert_equal("Homer an der Uni", seasons[5][3])
        assert_equal("Hochzeit auf Indisch", seasons[9][7])
        assert_equal("G.I. Homer", seasons[18][5])
        assert_equal("Die Farbe Gelb", seasons[21][13])

        data = wiki.get("Liste der Misfits-Episoden")
        seasons = Plugin::Wikipedia.parse_episodelist_page_data(data)

        assert_equal("Das Gewitter", seasons[1][1])
        assert_equal("Nathan wird Vater", seasons[2][7])
    end

    def test_inpage_episode_list_page_data_extraction
        wiki = MediaWiki::Gateway.new('http://de.wikipedia.org/w/api.php')

        data = wiki.get("The Glades")
        seasons = Plugin::Wikipedia.parse_inarticle_episodelist_page_data(data)

        assert_equal("Reptilien im Paradies", seasons[1][1])
        assert_equal("Doppelgänger", seasons[1][6])
        assert_equal("Unruhiges Blut", seasons[1][9])

        data = wiki.get("Royal Pains")
        seasons = Plugin::Wikipedia.parse_inarticle_episodelist_page_data(data)

        assert_equal("Auch Reiche sind nur Menschen", seasons[1][1])
        assert_equal("Krank vor Liebe", seasons[2][2])
        assert_equal("Mich trifft der Blitz", seasons[2][16])

        data = wiki.get("Flashpoint – Das Spezialkommando")
        seasons = Plugin::Wikipedia.parse_inarticle_episodelist_page_data(data, true)

        assert_equal("Skorpion", seasons[1][1])
        assert_equal("Die Festung", seasons[2][2])
        assert_equal("Der Beschützer", seasons[2][16])

        data = wiki.get("Dr. Dani Santino – Spiel des Lebens")
        seasons = Plugin::Wikipedia.parse_inarticle_episodelist_page_data(data)

        assert_equal("Touchdown", seasons[1][1])
        assert_equal("Zickenkrieg", seasons[1][7])
    end


    def test_episode_information_generation

        flpo = Serienrenamer::Episode.new(@@valid_filenames['flpo'])
        data = Plugin::Wikipedia.generate_episode_information(flpo)[0]
        flpo.add_episode_information(data, false) if data
        assert_equal("S04E04 - Getrübte Erinnerungen.avi", flpo.to_s)

        two = Serienrenamer::Episode.new(@@valid_filenames['two'])
        data = Plugin::Wikipedia.generate_episode_information(two)[0]
        two.add_episode_information(data, false) if data
        assert_equal("S09E07 - Das Tagebuch.avi", two.to_s)

        simp = Serienrenamer::Episode.new(@@valid_filenames['simp'])
        data = Plugin::Wikipedia.generate_episode_information(simp)[0]
        simp.add_episode_information(data, false) if data
        assert_equal("S09E07 - Hochzeit auf Indisch.avi", simp.to_s)

        chuck = Serienrenamer::Episode.new(@@valid_directories['chuck'])
        data = Plugin::Wikipedia.generate_episode_information(chuck)[0]
        chuck.add_episode_information(data, false) if data
        assert_equal("S01E01 - Pilot.avi", chuck.to_s)

        chuck2 = Serienrenamer::Episode.new(@@valid_directories['chuck2'])
        data = Plugin::Wikipedia.generate_episode_information(chuck2)[0]
        chuck2.add_episode_information(data, false) if data
        assert_equal("S02E10 - Chuck gegen zehn Millionen.avi", chuck2.to_s)

        dani = Serienrenamer::Episode.new(@@valid_filenames['dani'])
        data = Plugin::Wikipedia.generate_episode_information(dani)[0]
        dani.add_episode_information(data, false) if data
        assert_equal("S01E04 - Gewohnheiten.avi", dani.to_s)
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

    def test_check_for_inarticle_episode_list

        wiki = MediaWiki::Gateway.new('http://de.wikipedia.org/w/api.php')

        assert_equal(false, Plugin::Wikipedia.contains_inarticle_episode_list?(wiki.get("Bones")))
        assert_equal(true,  Plugin::Wikipedia.contains_inarticle_episode_list?(wiki.get("The Glades")))
        assert_equal(true,  Plugin::Wikipedia.contains_inarticle_episode_list?(wiki.get("Royal Pains")))

    end

end
