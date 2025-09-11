# frozen_string_literal: true

require "thor"
require "pry"
require 'tty-table'
require 'colorize'
require 'json'
require_relative "fat_model_finder/version"

module FatModelFinder
  class Error < StandardError; end

  class FileData
    attr_accessor :line_count, :file_name, :file_size, :file_extension, :last_modified, :word_count, :char_count,
    :is_empty, :file

    def initialize(file:)
      @file = file
    end

    def set_attributes
      @line_count = File.foreach(@file).count
      @file_name = File.basename(@file)
      @file_size = File.size(@file)
      @file_extension = File.extname(@file)
      @last_modified = File.mtime(@file)
      @word_count = File.read(@file).split.size
      @char_count = File.read(@file).length
      @is_empty = File.zero?(@file)
    end

    # Convert the object to a hash for JSON serialization we will use it later when we want to re-query the saved
    # file data...
    def to_h
      {
        file_name: @file_name,
        file_size: @file_size,
        file_extension: @file_extension,
        last_modified: @last_modified,
        line_count: @line_count,
        word_count: @word_count,
        char_count: @char_count,
        is_empty: @is_empty
      }
    end
  end

  class FileDataPresenter
    def self.display(file_data:)
      # TODO: get rid of TTY because it breaks tests...
      table = TTY::Table.new(
        ['Attribute'.colorize(:cyan), 'Value'.colorize(:cyan)],
        [
          ['File Name'.colorize(:cyan), file_data.file_name.colorize(:green)],
          ['File Size'.colorize(:cyan), "#{file_data.file_size} bytes".colorize(:green)],
          ['File Extension'.colorize(:cyan), file_data.file_extension.colorize(:green)],
          ['Last Modified'.colorize(:cyan), file_data.last_modified.to_s.colorize(:green)],
          ['Line Count'.colorize(:cyan), file_data.line_count.to_s.colorize(:green)],
          ['Word Count'.colorize(:cyan), file_data.word_count.to_s.colorize(:green)],
          ['Character Count'.colorize(:cyan), file_data.char_count.to_s.colorize(:green)],
          ['Is Empty'.colorize(:cyan), (file_data.is_empty ? 'Yes'.colorize(:red) : 'No'.colorize(:green))]
        ]
      )

      puts table.render(:ascii)
    end
  end

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
          # FileDataPresenter.display(file_data: set_file_data)

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
