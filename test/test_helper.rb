require 'stringio'
require 'test/unit'
require 'vcr'
require File.dirname(__FILE__) + '/../lib/serienrenamer'
require File.dirname(__FILE__) + '/../lib/serienrenamer/plugin'

class TestHelper

  TESTFILE_DIRECTORY = File.join(File.dirname(__FILE__), 'testfiles')

  class << self

    # create the supplied Files in the testfiles directory
    def create_test_files(files)
      _create_testfile_directory

      files.each do |f|
        FileUtils.touch File.join(TESTFILE_DIRECTORY, f)
      end
    end

    # create supplied directories with an sample video file
    def create_test_dirs(directories)
      _create_testfile_directory

      directories.each do |d|
        dir = File.join(TESTFILE_DIRECTORY, d)

        FileUtils.mkdir(dir) unless File.directory?(dir)
        FileUtils.touch(File.join(dir, 'episode.avi'))
      end
    end

    # write file with episode Text
    def write_episode_textfile(dir, title, filename="filename.txt")
      dirpath = File.join(TESTFILE_DIRECTORY, dir)

      create_test_dirs([ dir ]) unless File.directory?(dirpath)

      filenametxt = File.new(File.join(dirpath, filename), "w")
      filenametxt.write(title)
      filenametxt.close
    end

    # change the working directory to TESTFILE_DIRECTORY
    def cwd
      Dir.chdir(TESTFILE_DIRECTORY)
    end

    # remove testfile directory
    def clean
      if File.directory?(TESTFILE_DIRECTORY)
        system("rm -rf #{TESTFILE_DIRECTORY}")
      end
    end

    def _create_testfile_directory
      FileUtils.mkdir(TESTFILE_DIRECTORY) unless
      File.directory?(TESTFILE_DIRECTORY)
    end
  end
end

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), 'vcr_cassettes')
  c.hook_into :fakeweb
  c.allow_http_connections_when_no_cassette = true
end

module Kernel
  private

  # get the current method name as an unique identifier for the vcr_cassettes
  def method_name
    caller[0] =~ /`([^']*)'/ and $1
  end
end
