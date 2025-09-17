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
        before_save :do_something
        before_save :do_something
        before_save :do_something
        before_save :do_something
        before_save :do_something

        validates :name, presence: true
        validates :name, presence: true
        validates :name, presence: true
        validates :name, presence: true
        validates :name, presence: true
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

    assert_equal 6, file_data.first["callback_count"], "Expected callback count to match"
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

    assert_equal 6, file_data.first["validation_count"], "Expected validation count to match"
  end

  def test_that_models_can_be_flagged_as_fat
    cli = FatModelFinder::CLI.new
    cli.scan(@test_directory)

    file_data = JSON.parse(File.read(@output_file))

    assert_equal true, file_data.first["fat"], "Expected fat to be true"
  end

  def test_that_fat_model_data_is_set
    cli = FatModelFinder::CLI.new
    cli.scan(@test_directory)

    file_data = JSON.parse(File.read(@output_file))

    assert_equal true, file_data.first["fat_model_data"]["callback_count_high"], "Expected callback_count_high"
    assert_equal true, file_data.first["fat_model_data"]["validation_count_high"], "Expected validation_count_high"
  end


  def test_show_fat_models_displays_fat_model_information
    cli = FatModelFinder::CLI.new
    cli.scan(@test_directory)

    File.write(@output_file, JSON.dump([{ "file_name" => "test_file.rb", "fat" => true }]))

    output = capture_io { cli.show_fat_models }.first

    assert_includes output, "Your Fat Models are..."
    assert_includes output, "test_file.rb"
  end

  def test_show_fat_models_displays_no_fat_models_message
    cli = FatModelFinder::CLI.new
    cli.scan(@test_directory)

    File.write(@output_file, JSON.dump([{ "file_name" => "test_file.rb", "fat" => false }]))

    output = capture_io { cli.show_fat_models }.first

    assert_includes output, "Nothing to worry about you have no Fat Models!"
  end

  def test_show_fat_models_displays_no_data_message
    cli = FatModelFinder::CLI.new

    File.write(@output_file, JSON.dump([]))

    output = capture_io { cli.show_fat_models }.first

    assert_includes output, "No data found. Run 'scan' first."
  end
end
