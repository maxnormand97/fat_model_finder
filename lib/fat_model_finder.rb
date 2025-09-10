# frozen_string_literal: true

require "thor"
require "pry"
require_relative "fat_model_finder/version"

module FatModelFinder
  class Error < StandardError; end

  # TODO: we could make this a builder class?
  class FileData
    attr_accessor :line_count, :file_name, :file_size, :file_extension, :last_modified, :word_count, :char_count,
    :is_empty

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

    def display_attributes
      <<~OUTPUT
        File Name:        #{@file_name}
        File Size:        #{@file_size} bytes
        File Extension:   #{@file_extension}
        Last Modified:    #{@last_modified}
        Line Count:       #{@line_count}
        Word Count:       #{@word_count}
        Character Count:  #{@char_count}
        Is Empty:         #{@is_empty ? 'Yes' : 'No'}
      OUTPUT
    end
  end

  # TODO: we could make a presenter to format the data.
  class FileDataPresenter
    def initialize(file:)
      @file = file
    end
  end

  # Interface for the program to the CLI
  class CLI < Thor
    desc "scan DIRECTORY", "Scan a directory in a Rails app"
    def scan(directory = "app/models")
      puts "Scanning directory: #{directory}"

      # Check if the directory exists
      unless Dir.exist?(directory)
        puts "Directory not found: #{directory}"
        return
      end

      # List all files in the directory
      # when we do the loop here thats what we will have to extract...
      files = Dir.glob("#{directory}/**/*")
      # TODO: we could store all the file_data to an instance variable so we can later on use it with other commands?
      all_file_data = []
      files.each do |file|
        if File.file?(file) # Ensure it's a file and not a directory TODO: will it be bale to handle directories?
          puts "#{file} - Setting file data"
          file_data = FileData.new(file:)
          file_data.set_attributes
          all_file_data << file_data
          puts file_data.display_attributes
        else
          puts "#{file} - [Not a file]"
        end
      end
    end
  end

  # Fat model finder
  # It will scan a rails repo specifically in the /models dir
  # it will go through each file and count the amount of lines that file has
    # the output will be ordered highest to lowest
    # the bigger files will be flagged based on an average of the total line length
  # it provide a CLI output with links to the files flagged
  # it will output how many relationships the model has
  # it will output how many validations the model has
  # it will look for other code smells
  # BONUS it will provide some kind of text or html output
end
