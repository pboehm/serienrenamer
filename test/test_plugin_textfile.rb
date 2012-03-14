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
    }

    def setup
        TestHelper.write_episode_textfile(
            @@directories["hmym"],
            "How.I.Met.Your.Mother.S07E05.Die.Exkursion.German.Dubbed.HDTV.XviD-ITG"
        )
        TestHelper.cwd
    end

    def teardown
        TestHelper.clean
    end

    def test_information_extraction
        how = Serienrenamer::Episode.new(@@directories['hmym'])
        data = Plugin::Textfile.generate_episode_information(how)[0]
        how.add_episode_information(data, true)
        assert_equal("S07E05 - Die Exkursion.avi", how.to_s)
    end

    def test_information_extraction_with_directory_parameter
        how = @@directories['hmym']
        data = Plugin::Textfile.generate_episode_information(how)[0]
        assert_not_nil(data)
    end
end
