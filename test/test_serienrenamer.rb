require File.dirname(__FILE__) + '/test_helper.rb'


class TestSerienrenamer < Test::Unit::TestCase

  def setup
  end
  
  def test_truth
    assert true
  end

  def test_episode_creation
      episode = Serienrenamer::Episode.new('Chuck')
      assert_equal(true, episode.is_a?(Serienrenamer::Episode)) 
  end

  def test_episode_name_detection
      episode = Serienrenamer::Episode.new('Chuck.S01E01.Dies.ist.ein.Test.German.Dubbed.avi')
      assert_equal(true, episode.is_episode?) 

      episode = Serienrenamer::Episode.new('chuck.512.hdtv-lol.avi')
      assert_equal(true, episode.is_episode?) 

      episode = Serienrenamer::Episode.new('video.flv')
      assert_equal(false, episode.is_episode?) 
  end

end
