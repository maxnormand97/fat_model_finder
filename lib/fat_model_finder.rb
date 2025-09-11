# frozen_string_literal: true

require "thor"
require "pry"
require 'colorize'
require 'json'
require_relative "fat_model_finder/version"
require_relative "fat_model_finder/file_data"
require_relative "fat_model_finder/file_data_presenter"

module FatModelFinder
  class Error < StandardError; end

  # Interface for the program to the CLI
  class CLI < Thor
    DATA_FILE = "file_data.json" # File to store data

    # TODO: we need to implement a --help feature that will output all of our descriptions
    desc "scan DIRECTORY", "Scan a directory in a Rails app and save file data to a JSON file"
    def scan(directory = "app/models")
      puts "Scanning directory: #{directory}"

      # Check if the directory exists
      unless Dir.exist?(directory)
        puts "Directory not found: #{directory}"
        return
      end

      # Load existing data from the file, or initialize an empty array file will be overwritten.
      all_file_data = if File.exist?(DATA_FILE)
        JSON.parse(File.read(DATA_FILE))
      else
        # will this ever get hit?
        []
      end

      # List all files in the directory
      files = Dir.glob("#{directory}/**/*")
      all_file_data = []
      files.each do |file|
        # TODO: we will have to add in some logic so it can traverse directories later
        next unless File.file?(file) # Skip directories

        # Check if the file is already in the data
        unless all_file_data.any? { |entry| entry["file"] == file }
          puts "#{file} - Adding new file"
          puts "File Details"
          set_file_data = FileData.new(file:)
          set_file_data.set_attributes
          FileDataPresenter.display(file_data: set_file_data)

          # Add the file's attributes to the data
          all_file_data << set_file_data.to_h
        else
          puts "#{file} - [Duplicate, skipping]"
        end
      end

      # Save updated data to the file
      File.write(DATA_FILE, JSON.dump(all_file_data))
      puts "Updated file data saved to #{DATA_FILE}"
    end

    desc "show_fat_models", "Will output details based on file_data JSON file"
    def do_stuff
      if File.exist?(DATA_FILE)
        all_file_data = JSON.parse(File.read(DATA_FILE))
        puts "In another method"
        puts "Stored file data:"
        puts all_file_data
      else
        puts "No data found. Run 'scan' first."
      end
    end
  end
end
