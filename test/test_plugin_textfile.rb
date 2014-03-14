# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'

#
# test class for the TextfileEpisodeInfo plugin that
# searches for textfiles with suitable episode
# information
#
class TestPluginTextfile < Test::Unit::TestCase
  @@directories = {
    'hmym'  => 'HMMG.705',
    'hmmg'  => 'HMMG.711',
  }

  def setup
    TestHelper.write_episode_textfile(
      @@directories["hmym"],
      "How.I.Met.Your.Mother.S07E05.Die.Exkursion.German.Dubbed.HDTV.XviD-ITG"
    )

    # two files which contains possible information
    TestHelper.write_episode_textfile(
      @@directories["hmmg"],
      "How.I.Met.Your.Mother.S07E11.Plan.B.German.Dubbed.HDTV.XviD-ITG"
    )
    TestHelper.write_episode_textfile(
      @@directories["hmmg"],
      "Show ......... : How I Met Your Mother 7x11
            IMDB ......... : http://www.imdb.com/title/tt0460649/
            Notes ........ : ",
            "nfo.nfo"
    )
    TestHelper.cwd
  end

  def teardown
    TestHelper.clean
  end

  def test_information_extraction
    how = Serienrenamer::Episode.new(@@directories['hmym'])
    data = Serienrenamer::Plugin::Textfile.generate_episode_information(how)[0]
    how.add_episode_information(data, true)
    assert_equal("S07E05 - Die Exkursion.avi", how.to_s)
  end

  def test_select_right_textfile
    how = Serienrenamer::Episode.new(@@directories['hmmg'])
    data = Serienrenamer::Plugin::Textfile.generate_episode_information(how)[0]
    how.add_episode_information(data, true)
    assert_equal("S07E11 - Plan B.avi", how.to_s)
  end

  def test_information_extraction_with_directory_parameter
    how = @@directories['hmym']
    data = Serienrenamer::Plugin::Textfile.generate_episode_information(how)[0]
    assert_not_nil(data)
  end
end
