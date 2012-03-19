# encoding: UTF-8
require File.dirname(__FILE__) + '/test_helper.rb'
require 'yaml'

# test class for the merge_with_serialized option of the Hash class
# which is added to the class of the standard library
class TestHash < Test::Unit::TestCase

    @@TEST_DATA = {
        :first  => "first parameter",
        :second => "second parameter",
        :third  => "third parameter"
    }

    @@TEST_CONFIG_FILE =
        File.join(TestHelper::TESTFILE_DIRECTORY, "config.yml")
    @@TEST_EMPTY_CONFIG_FILE =
        File.join(TestHelper::TESTFILE_DIRECTORY, "empty.yml")
    @@TEST_INVALID_CONFIG_FILE =
        File.join(TestHelper::TESTFILE_DIRECTORY, "invalid.yml")
    @@TEST_NOT_EXISTING =
        File.join(TestHelper::TESTFILE_DIRECTORY, "not_exisiting.yml")

    def setup
        TestHelper.create_test_files([])
        @modified = @@TEST_DATA.merge({:third => "modified third parameter"})

        File.open(@@TEST_CONFIG_FILE, 'w') {|f| f.write(@modified.to_yaml) }
        File.open(@@TEST_EMPTY_CONFIG_FILE, 'w') {|f| f.write(Hash.new.to_yaml) }
        File.open(@@TEST_EMPTY_CONFIG_FILE, 'w') {|f| f.write("invalid") }

    end

    def teardown
        TestHelper.clean
    end

    def test_merge_valid_yaml_file
        merged = @@TEST_DATA.merge_with_serialized(@@TEST_CONFIG_FILE)
        assert_equal("modified third parameter", merged[:third])
    end

    def test_merge_invalid_empty_and_not_exisiting_yaml_file
        merged = @@TEST_DATA.merge_with_serialized(@@TEST_EMPTY_CONFIG_FILE)
        assert_equal("third parameter", merged[:third])

        merged = @@TEST_DATA.merge_with_serialized(@@TEST_INVALID_CONFIG_FILE)
        assert_equal("third parameter", merged[:third])

        merged = @@TEST_DATA.merge_with_serialized(@@TEST_NOT_EXISTING)
        assert_equal("third parameter", merged[:third])
    end

end
