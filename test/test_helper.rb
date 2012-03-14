require 'stringio'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/serienrenamer'
require File.dirname(__FILE__) + '/../lib/plugin'

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

            filenametxt = File.new(File.join(dirpath, "filename.txt"), "w")
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
