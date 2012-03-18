# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'
require 'fileutils'

class TestEpisode < Test::Unit::TestCase

    @@files = {
        'chuckfull' => 'Chuck.S01E01.Dies.ist.ein.Test.German.Dubbed.BLURAYRiP.DELiCiOUS.WEBRiP.CiD.avi',
        'chuck1' => 'chuck.512.hdtv-lol.avi',
        'chuck2' => 'chuck.1212.hdtv-lol.avi',
        'chuck3' => 'chuck.5x12.hdtv-lol.avi',
        'without'=> '5x12.avi',
        'royal'  => 'Royal.Pains.S02E10.Beziehungsbeschwerden.GERMAN.DUBBED.DVDRiP.XviD-SOF.avi',
        'flpo'   => 'Flashpoint.S04E04.Getruebte.Erinnerungen.German.Dubbed.WEB-DL.XViD.avi',
        'csiny'  => 'sof-csi.ny.s07e20.avi',
        'legaltrash' =>'flpo.404.Die.German.Erinnerungen.German.Dubbed.WEB-DL.XViD.avi',
    }

    @@directories = {
        'chuck'  => 'Chuck.S01E01.Testepisode.German.Dubbed.BLURAYRiP',
        'chuck1' => 'Chuck.101.First.Episode.German.Dubbed.BLURAYRiP',
        'chuck2' => 'chuck.2x12',
        'ncis'   => 'NCIS.S09E05.Im.sicheren.Hafen.GERMAN.DUBBED.DL.720p.HDTV.x264-euHD',
    }

    @@invalid_directories = {
        'tbbt'   => 'BBTV.16/',
    }

    def setup
        TestHelper.create_test_files(@@files.values)
        TestHelper.create_test_dirs(@@directories.values)
        TestHelper.create_test_dirs(@@invalid_directories.values)
        TestHelper.cwd
    end

    def teardown
        TestHelper.clean
    end

    def test_episode_name_detection

        @@files.each { |name,file|
            assert_equal(true,
                Serienrenamer::Episode.contains_episode_information?(file))

            assert_equal(false,
                Serienrenamer::Episode.extract_episode_information(file).nil?)
        }

        @@directories.each { |name,dir|
            assert_equal(true,
                Serienrenamer::Episode.contains_episode_information?(dir))

            assert_equal(false,
                Serienrenamer::Episode.extract_episode_information(dir).nil?)
        }

        assert_equal(false,
                Serienrenamer::Episode.contains_episode_information?('video.flv'))

        assert_equal(true,
            Serienrenamer::Episode.extract_episode_information('video.flv').nil?)
    end

    def test_information_cleanup
        assert_equal("Im sicheren Hafen",
                     Serienrenamer::Episode.clean_episode_data(
                        ".Im.sicheren.Hafen.GERMAN.DUBBED.DL.720p.HDTV.x264-euHD",
                        true, true)
        )
    end

    def test_repairing_umlauts
        assert_equal("Duell",
                     Serienrenamer::Episode.repair_umlauts("Duell"))
        assert_equal("für",
                     Serienrenamer::Episode.repair_umlauts("fuer"))
        assert_equal("Änderung",
                     Serienrenamer::Episode.repair_umlauts("Aenderung"))
        assert_equal("Zaubersprüche",
                     Serienrenamer::Episode.repair_umlauts("Zaubersprueche"))
        assert_equal("Ungeheuerlich",
                     Serienrenamer::Episode.repair_umlauts("Ungeheuerlich"))
        assert_equal("Frauen",
                     Serienrenamer::Episode.repair_umlauts("Frauen"))
        assert_equal("Abführmittel",
                     Serienrenamer::Episode.repair_umlauts("Abfuehrmittel"))
        assert_equal("tödlich",
                     Serienrenamer::Episode.repair_umlauts("toedlich"))
        assert_equal("König",
                     Serienrenamer::Episode.repair_umlauts("Koenig"))
        assert_equal("Öko",
                     Serienrenamer::Episode.repair_umlauts("Oeko"))
        assert_equal("Männer",
                     Serienrenamer::Episode.repair_umlauts("Maenner"))
        assert_equal("Draufgänger",
                     Serienrenamer::Episode.repair_umlauts("Draufgaenger"))
        assert_equal("Unglücksvögel",
                     Serienrenamer::Episode.repair_umlauts("Ungluecksvoegel"))
        assert_equal("Jäger",
                     Serienrenamer::Episode.repair_umlauts("Jaeger"))
        assert_equal("Loyalität",
                     Serienrenamer::Episode.repair_umlauts("Loyalitaet"))
        # both forms not existing
        assert_equal("Moeback",
                     Serienrenamer::Episode.repair_umlauts("Moeback"))
    end

    def test_episode_information_extraction_from_file

        assert_raise(ArgumentError) { Serienrenamer::Episode.new('video.flv')}

        epi = Serienrenamer::Episode.new(@@files["chuckfull"])
        assert_equal('Chuck',epi.series)
        assert_equal(1, epi.season)
        assert_equal(1, epi.episode)
        assert_equal("Dies ist ein Test", epi.episodename)
        assert_equal("S01E01 - Dies ist ein Test.avi", epi.to_s)

        flpo = Serienrenamer::Episode.new(@@files["flpo"])
        assert_equal("S04E04 - Getrübte Erinnerungen.avi", flpo.to_s)

        csiny = Serienrenamer::Episode.new(@@files["csiny"])
        csiny.episodename_needed=false
        assert_equal("S07E20.avi", csiny.to_s)

        legaltrash = Serienrenamer::Episode.new(@@files["legaltrash"])
        assert_equal("S04E04 - Die German Erinnerungen.avi", legaltrash.to_s)

        royal = Serienrenamer::Episode.new(@@files["royal"])
        assert_equal("S02E10 - Beziehungsbeschwerden.avi", royal.to_s)
    end

    def test_episode_information_extraction_from_directory

        chuck = Serienrenamer::Episode.new(@@directories["chuck"])
        assert_equal("S01E01 - Testepisode.avi", chuck.to_s)

        chuck1 = Serienrenamer::Episode.new(@@directories["chuck1"])
        assert_equal("S01E01 - First Episode.avi", chuck1.to_s)

        ncis = Serienrenamer::Episode.new(@@directories["ncis"])
        assert_equal("S09E05 - Im sicheren Hafen.avi", ncis.to_s)

        chuck2 = Serienrenamer::Episode.new(@@directories["chuck2"])
        chuck2.episodename_needed=false
        assert_equal("S02E12.avi", chuck2.to_s)
    end

    def test_adding_episodename_afterwards

        csiny = Serienrenamer::Episode.new(@@files["csiny"])
        csiny.add_episode_information('Dies ist nachträglich eingefügt', false)
        assert_equal("S07E20 - Dies ist nachträglich eingefügt.avi", csiny.to_s)

        chuck = Serienrenamer::Episode.new(@@directories["chuck"])
        chuck.add_episode_information(
            'Chuck.S01E01.First.Episode.GERMAN.DUBBED.DL.720p.HDTV.x264-euHD',
            true)
        assert_equal("S01E01 - First Episode.avi", chuck.to_s)
    end

    def test_videofile_determination
        @@files.each { |n,f|
            assert_not_nil(Serienrenamer::Episode.determine_video_file(f))
        }

        @@directories.each { |n,d|
            assert_not_nil(Serienrenamer::Episode.determine_video_file(d))
        }
    end

    def test_episode_rename_file
        epi = Serienrenamer::Episode.new(@@files["chuckfull"])
        epi.rename
        assert_equal(true, epi.success)
    end

    def test_episode_rename_from_directory
        @@directories.each do |n,d|
            epi = Serienrenamer::Episode.new(d)
            epi.rename
            assert_equal(true, epi.success)
        end
    end

    def test_episode_where_dir_has_not_enough_info
        d = @@invalid_directories["tbbt"]

        filenametxt = File.new(File.join(d, "filename.txt"), "w")
        filenametxt.write(
            "The.Big.Bang.Theory.S05E16.Sheldon.Revival.HDTV.XviD-LOL")
        filenametxt.close

        tbbt = Serienrenamer::Episode.new(d)
        assert_equal("S05E16 - Sheldon Revival.avi", tbbt.to_s)

        tbbt.rename
        assert_equal(true, tbbt.success)
    end

    def test_generate_episode_hash
        chuck = Serienrenamer::Episode.new(@@directories["chuck"])

        videofile = File.new(chuck.episodepath, "w")
        videofile.write("Chuck.S01E01.Testepisode.German.Dubbed.BLURAYRiP")
        videofile.close

        assert_equal("d538bf7632bd3b14601015fbc3a39f60", chuck.md5sum)
        chuck.rename
        assert_equal("d538bf7632bd3b14601015fbc3a39f60", chuck.md5sum)
    end
end
