# frozen_string_literal: true

require "test_helper"

class TestFatModelFinder < Minitest::Test
  def setup
    @test_directory = "test_directory"
    @test_file = "#{@test_directory}/test_file.rb"
    @output_file = "file_data.json"

    # Create a test directory and file
    Dir.mkdir(@test_directory) unless Dir.exist?(@test_directory)
    File.write(@test_file, <<~RUBY)
      class Test
        before_save :do_something
        validates :name, presence: true
        has_many :items

        def method_one
        end

        def method_two
        end
      end
    RUBY

    # Ensure the output file does not exist before running the scan
    File.delete(@output_file) if File.exist?(@output_file)
  end

  def teardown
    # Cleanup test files and directories
    File.delete(@test_file) if File.exist?(@test_file)
    Dir.rmdir(@test_directory) if Dir.exist?(@test_directory)
    File.delete(@output_file) if File.exist?(@output_file)
  end

  def test_that_json_file_is_created
    cli = FatModelFinder::CLI.new
    cli.scan(@test_directory)

    assert File.exist?(@output_file), "Expected JSON file to be created"
  end

  def test_that_json_file_contains_correct_file_entry
    cli = FatModelFinder::CLI.new
    cli.scan(@test_directory)

    file_data = JSON.parse(File.read(@output_file))

    assert_equal 1, file_data.size, "Expected one file entry in the JSON file"
    assert_equal "test_file.rb", file_data.first["file_name"], "Expected file name to match"
  end

  def test_that_json_file_contains_correct_method_count
    cli = FatModelFinder::CLI.new
    cli.scan(@test_directory)

    file_data = JSON.parse(File.read(@output_file))

    assert_equal 2, file_data.first["method_count"], "Expected method count to match"
  end

  def test_that_json_file_contains_correct_callback_count
    cli = FatModelFinder::CLI.new
    cli.scan(@test_directory)

    file_data = JSON.parse(File.read(@output_file))

    assert_equal 1, file_data.first["callback_count"], "Expected callback count to match"
  end

  def test_that_json_file_contains_correct_association_count
    cli = FatModelFinder::CLI.new
    cli.scan(@test_directory)

    file_data = JSON.parse(File.read(@output_file))

    assert_equal 1, file_data.first["association_count"], "Expected association count to match"
  end

  def test_that_json_file_contains_correct_validation_count
    cli = FatModelFinder::CLI.new
    cli.scan(@test_directory)

    file_data = JSON.parse(File.read(@output_file))

    assert_equal 1, file_data.first["validation_count"], "Expected validation count to match"
  end
end

  # It will scan a rails repo specifically in the /models dir
  # it will go through each file and count the amount of lines that file has
    # the output will be ordered highest to lowest
    # the bigger files will be flagged based on an average of the total line length
  # it provide a CLI output with links to the files flagged
  # it will output how many relationships the model has
  # it will output how many validations the model has
  # it will look for other code smells
  # BONUS it will provide some kind of text or html output
