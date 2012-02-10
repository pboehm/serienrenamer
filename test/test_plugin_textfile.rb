# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'
require 'serienrenamer/episode.rb'

#
# test class for the TextfileEpisodeInfo plugin that
# searches for textfiles with suitable episode
# information
#
class TestPluginTextfile < Test::Unit::TestCase
    @@valid_directories = {
        'hmym'  => 'test/testfiles/HMMG.705',
    }

    def setup
        system('rm -r test/testfiles/*')

        d = @@valid_directories["hmym"]
        FileUtils.mkdir(d)
        FileUtils.touch(File.join(d, 'episode.avi'))

        filenametxt = File.new(File.join(d, "filename.txt"), "w")
        filenametxt.write("How.I.Met.Your.Mother.S07E05.Die.Exkursion.German.Dubbed.HDTV.XviD-ITG")
        filenametxt.close
    end

    def test_information_extraction
        how = Serienrenamer::Episode.new(@@valid_directories['hmym'])
        data = TextfileEpisodeInfo.generate_episode_information(how)[0]
        how.add_episodename(data, true)
        assert_equal("S07E05 - Die Exkursion.avi", how.to_s)
    end

    def test_information_extraction_with_directory_parameter
        how = @@valid_directories['hmym']
        data = TextfileEpisodeInfo.generate_episode_information(how)[0]
        assert_not_nil(data)
    end
end
