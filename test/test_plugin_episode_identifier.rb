# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'

class TestPluginEpisodeIdentifier < Test::Unit::TestCase
  @@files = {
    'chuck'  => 'chuck.312.hdtv-lol.avi',
    'csiny'  => 'sof-csi.ny.s07e01.avi',
    'simps'  => 'simpsons.s22e16.avi',
  }

  def setup
    @plugin = Plugin::EpisodeIdentifier
    TestHelper.create_test_files(@@files.values)
    TestHelper.cwd
  end

  def teardown
    TestHelper.clean
  end

  def test_information_extraction

    simps = Serienrenamer::Episode.new(@@files['simps'])
    data = @plugin.generate_episode_information(simps)[0]
    simps.add_episode_information(data, true)
    assert_equal("S22E16 - Episode 16.avi", simps.to_s)

    chuck = Serienrenamer::Episode.new(@@files['chuck'])
    data = @plugin.generate_episode_information(chuck)[0]
    chuck.add_episode_information(data, true)
    assert_equal("S03E12 - Episode 12.avi", chuck.to_s)

    csiny = Serienrenamer::Episode.new(@@files['csiny'])
    data = @plugin.generate_episode_information(csiny)[0]
    csiny.add_episode_information(data, true)
    assert_equal("S07E01 - Episode 1.avi", csiny.to_s)
  end
end
