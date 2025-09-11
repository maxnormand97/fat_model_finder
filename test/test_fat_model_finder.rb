# frozen_string_literal: true

require "test_helper"

class TestFatModelFinder < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::FatModelFinder::VERSION
  end

  # TODO: we are going to have to extract the setup and teardown logic to be more useful, as well as running the
  # actual scan method... This is for now effectively an integration test...
  def test_that_it_will_output_a_json_file
    # Setup
    test_directory = "test_directory"
    test_file = "#{test_directory}/test_file.rb"
    output_file = "file_data.json"

    # Create a test directory and file
    Dir.mkdir(test_directory) unless Dir.exist?(test_directory)
    File.write(test_file, "class Test; end")

    # Ensure the output file does not exist before running the scan
    File.delete(output_file) if File.exist?(output_file)

    # Run the scan method
    cli = FatModelFinder::CLI.new
    cli.scan(test_directory)

    # Assertions
    assert File.exist?(output_file), "Expected JSON file to be created"
    file_data = JSON.parse(File.read(output_file))
    assert_equal 1, file_data.size, "Expected one file entry in the JSON file"
    assert_equal "test_file.rb", file_data.first["file_name"], "Expected file name to match"

    # Cleanup
    File.delete(test_file) if File.exist?(test_file)
    Dir.rmdir(test_directory) if Dir.exist?(test_directory)
    File.delete(output_file) if File.exist?(output_file)
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
