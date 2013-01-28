# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'
require 'fileutils'
require 'tempfile'

class TestInformationStore < Test::Unit::TestCase

  @@files = {
    'chuckfull' => 'Chuck.S01E01.Dies.ist.ein.Test.German.Dubbed.BLURAYRiP.DELiCiOUS.WEBRiP.CiD.avi',
    'royal'  => 'Royal.Pains.S02E10.Beziehungsbeschwerden.GERMAN.DUBBED.DVDRiP.XviD-SOF.avi',
    'flpo'   => 'Flashpoint.S04E04.Getruebte.Erinnerungen.German.Dubbed.WEB-DL.XViD.avi',
    'legaltrash' =>'flpo.404.Die.German.Erinnerungen.German.Dubbed.WEB-DL.XViD.avi',
  }

  def setup

    @empty_file = Tempfile.new('information_storage')

    VCR.use_cassette("info_store_#{method_name}") do
      TestHelper.create_test_files(@@files.values)
      TestHelper.cwd

      @episodes = Hash.new
      storage = Serienrenamer::InformationStore.new("storage.yml")

      @@files.each do |key, value|
        filenametxt = File.new(value, "w")
        filenametxt.write(value)
        filenametxt.close

        episode = Serienrenamer::Episode.new(value)
        episode.rename
        @episodes[key] = episode
        storage.store(episode)
      end
      storage.write
    end

  end

  def teardown
    TestHelper.clean
  end

  def test_information_storage

    storage = Serienrenamer::InformationStore.new("storage.yml")

    @episodes.each do |key, episode|
      assert_equal(storage.episode_hash[episode.md5sum], episode.series)
    end
  end

  def test_that_an_empty_information_storage_is_built_up_right

    storage = Serienrenamer::InformationStore.new(@empty_file.path)
    assert_equal storage.episode_hash, Hash.new
  end

end
