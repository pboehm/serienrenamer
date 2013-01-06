# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'

class TestPluginSerienjunkiesFeed < Test::Unit::TestCase
  @@files = {
    'chuck'  => 'chuck.312.hdtv-lol.avi',
    'flpo'   => 'Flashpoint.S04E04.German.Dubbed.WEB-DL.XViD.avi',
    'csiny'  => 'sof-csi.ny.s07e21.avi',
    'simps'  => 'simpsons.s22e16.avi',
    'biglove'=> 'idtv-big.love.s05e06.avi',
    'crmi'   => 'crmi-s06e22.avi',
    'two'    => 'Two.and.a.half.Men.S09E07.German.Dubbed.WS.WEB-DL.XviD-GDR.avi',
    'sea'    => 'tcpa-seapatrol_s05e11.avi',
    'shlock' => 'Sherlock.s02e01.avi',
    'unit'   => 'The.Unit.s01e17.avi',
  }

  @@directories = {
    'chuck'  => 'Chuck.S01E01.German.Dubbed.BLURAYRiP.WEB-DL',
  }

  def setup
    unless defined? @feed
      @feed = Serienrenamer::Plugin::SerienjunkiesOrgFeed
      @feed.feed_url = File.join( File.dirname(__FILE__),
                                 'serienjunkies_feed_sample.xml')
    end

    TestHelper.create_test_files(@@files.values)
    TestHelper.create_test_dirs(@@directories.values)
    TestHelper.cwd
  end

  def teardown
    TestHelper.clean
  end

  # improve this so that the Plugin uses a local xml file
  def test_information_extraction

    VCR.use_cassette("sjunkie_feed_#{method_name}") do
      simps = Serienrenamer::Episode.new(@@files['simps'])
      data = @feed.generate_episode_information(simps)[0]
      simps.add_episode_information(data, true)
      assert_equal("S22E16 - Ein Sommernachtstrip.avi", simps.to_s)

      flpo = Serienrenamer::Episode.new(@@files['flpo'])
      data = @feed.generate_episode_information(flpo)[0]
      flpo.add_episode_information(data, true)
      assert_equal("S04E04 - Getrübte Erinnerungen.avi", flpo.to_s)

      big = Serienrenamer::Episode.new(@@files['biglove'])
      data = @feed.generate_episode_information(big)[0]
      big.add_episode_information(data, true)
      assert_equal("S05E06 - Scheidung.avi", big.to_s)

      crmi = Serienrenamer::Episode.new(@@files['crmi'])
      data = @feed.generate_episode_information(crmi)[0]
      crmi.add_episode_information(data, true)
      assert_equal("S06E22 - Die Dunkelkammer Mörder.avi", crmi.to_s)

      two = Serienrenamer::Episode.new(@@files['two'])
      data = @feed.generate_episode_information(two)[0]
      two.add_episode_information(data, true)
      assert_equal("S09E07 - Das Tagebuch.avi", two.to_s)

      sea = Serienrenamer::Episode.new(@@files['sea'])
      data = @feed.generate_episode_information(sea)[0]
      sea.add_episode_information(data, true)
      assert_equal("S05E11 - Der Morgen danach.avi", sea.to_s)

      csiny = Serienrenamer::Episode.new(@@files['csiny'])
      data = @feed.generate_episode_information(csiny)[0]
      csiny.add_episode_information(data, true)
      assert_equal("S07E21 - Kugelhagel.avi", csiny.to_s)

      # the following episodes are not exisiting in the feed
      # so it should returns nil
      sherlock = Serienrenamer::Episode.new(@@files['shlock'])
      data = @feed.generate_episode_information(sherlock)[0]
      assert_nil(data)

      theunit = Serienrenamer::Episode.new(@@files['unit'])
      data = @feed.generate_episode_information(theunit)[0]
      assert_nil(data)
    end
  end
end
