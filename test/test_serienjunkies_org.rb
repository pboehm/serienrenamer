# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'

class TestSerienjunkiesOrg < Test::Unit::TestCase
  @@files = {
    'flpo'   => 'Flashpoint.S04E04.German.Dubbed.WEB-DL.XViD.avi',
    'dani'   => 'Dr.Dani.Santino.S01E04.German.Dubbed.WEB-DL.XViD.avi',
    'two'    => 'Two.and.a.half.Men.S06E07.German.Dubbed.WS.WEB-DL.XviD-GDR.avi',
    'sea'    => 'Sea.Patrol.s05e11.avi',
  }

  def setup
    TestHelper.create_test_files(@@files.values)
    TestHelper.cwd
  end

  def teardown
    TestHelper.clean
  end

  def test_seriespage_url_search

    VCR.use_cassette("sjunkie_org_#{method_name}") do
      plugin = Plugin::SerienjunkiesOrg

      misfits = plugin.find_link_to_series_page("Misfits")
      assert_equal("http://serienjunkies.org/serie/misfits/", misfits)

      thementalist = plugin.find_link_to_series_page("The Mentalist")
      assert_equal("http://serienjunkies.org/serie/the-mentalist/", thementalist)

      ncis = plugin.find_link_to_series_page("NCIS")
      assert_equal("http://serienjunkies.org/serie/ncis/", ncis)
    end
  end

  def test_parse_seriespage

    VCR.use_cassette("sjunkie_org_#{method_name}") do
      plugin = Plugin::SerienjunkiesOrg

      seasons = plugin.parse_seriespage(
        "http://serienjunkies.org/royal-pains/")
      assert_match(/Auch.Reiche.sind.nur.Menschen/, seasons['1_1'])
      assert_match(/Krank.vor.Liebe/, seasons['2_2'])

      seasons = plugin.parse_seriespage(
        "http://serienjunkies.org/serie/chuck/")
      assert_match(/Chuck.gegen.den.Intersect/, seasons['1_1'])
      assert_match(/Chuck.gegen.den.Tunnel.des.Schreckens/, seasons['4_6'])

      seasons = plugin.parse_seriespage("http://serienjunkies.org/ncis")
      assert_match(/Sprung.in.den.Tod/, seasons['1_2'])
      assert_match(/Fuer.immer.jung/, seasons['9_2'])
    end
  end

  def test_episode_information_generation

    VCR.use_cassette("sjunkie_org_#{method_name}") do
      plugin = Plugin::SerienjunkiesOrg

      flpo = Serienrenamer::Episode.new(@@files['flpo'])
      data = plugin.generate_episode_information(flpo)[0]
      flpo.add_episode_information(data, true) if data
      assert_equal("S04E04 - Getrübte Erinnerungen.avi", flpo.to_s)

      dani = Serienrenamer::Episode.new(@@files['dani'])
      data = plugin.generate_episode_information(dani)[0]
      dani.add_episode_information(data, true) if data
      assert_equal("S01E04 - Gewohnheiten.avi", dani.to_s)

      two = Serienrenamer::Episode.new(@@files['two'])
      data = plugin.generate_episode_information(two)[0]
      two.add_episode_information(data, true) if data
      assert_equal("S06E07 - Alles einsteigen.avi", two.to_s)

      sea = Serienrenamer::Episode.new(@@files['sea'])
      data = plugin.generate_episode_information(sea)[0]
      sea.add_episode_information(data, true) if data
      assert_equal("S05E11 - Der Morgen danach.avi", sea.to_s)
    end
  end
end
