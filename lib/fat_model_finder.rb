# frozen_string_literal: true

require "thor"
require "pry"
require 'json'
require 'colorize'
require_relative "fat_model_finder/version"
require_relative "fat_model_finder/file_data"
require_relative "fat_model_finder/file_data_presenter"

module FatModelFinder
  class Error < StandardError; end

  # Interface for the program to the CLI
  class CLI < Thor
    DATA_FILE = "file_data.json" # File to store data

    # Helper method to load file data
    no_commands do
      def load_file_data
        if File.exist?(DATA_FILE)
          file_content = File.read(DATA_FILE)
          file_content.empty? ? [] : JSON.parse(file_content)
        else
          []
        end
      end

      def save_file_data(data)
        # Clear the file data by overwriting with an empty array
        File.write(DATA_FILE, JSON.dump([])) if File.exist?(DATA_FILE)

        File.write(DATA_FILE, JSON.dump(data))
        puts "Updated file data saved to #{DATA_FILE}"
      end

      def directory_exists?(directory)
        unless Dir.exist?(directory)
          puts "Directory not found: #{directory}"
          return false
        end
        true
      end

      # TODO: We need some logic to determine weather a model if "Fat" or not...
      def process_file(file, all_file_data)
        return if all_file_data.any? { |entry| entry["file"] == file }

        puts "#{file} - Adding new file"
        set_file_data = FileData.new(file:)
        set_file_data.set_base_attributes
        set_file_data.count_methods
        set_file_data.count_callbacks
        set_file_data.count_associations
        set_file_data.count_validations
        FileDataPresenter.display(file_data: set_file_data)
        all_file_data << set_file_data.to_h
      end
    end

    # Command: Scan a directory
    desc "scan DIRECTORY", "Scan a directory in a Rails app and save file data to a JSON file"
    def scan(directory = "app/models")
      puts "Scanning directory: #{directory}"
      return unless directory_exists?(directory)

      all_file_data = load_file_data
      files = Dir.glob("#{directory}/**/*")

      files.each do |file|
        next unless File.file?(file) # Skip directories
        process_file(file, all_file_data)
      end

      save_file_data(all_file_data)
    end

    # Command: Show stored file data
    desc "show_fat_models", "Output details based on file_data JSON file"
    def show_fat_models
      all_file_data = load_file_data
      if all_file_data.empty?
        puts "No data found. Run 'scan' first."
      else
        # TODO: now here we have to output the biggest models...
        puts "Stored file data:"
        # Sort the array of hashes by line_count in descending order
        sorted_files = all_file_data.sort_by { |file| -file["line_count"] }
        puts sorted_files
      end
    end
  end
end
