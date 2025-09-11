# frozen_string_literal: true

require "thor"
require "pry"
require 'tty-table'
require 'colorize'
require_relative "fat_model_finder/version"

module FatModelFinder
  class Error < StandardError; end

  # TODO: we could make this a builder class?
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
  end

  class FileDataPresenter
    def self.display(file_data:)
      table = TTY::Table.new(
        ['Attribute'.colorize(:light_blue), 'Value'.colorize(:light_blue)], # Headers with color
        [
          ['File Name'.colorize(:cyan), file_data.file_name.colorize(:green)],
          ['File Size'.colorize(:cyan), "#{file_data.file_size} bytes".colorize(:yellow)],
          ['File Extension'.colorize(:cyan), file_data.file_extension.colorize(:magenta)],
          ['Last Modified'.colorize(:cyan), file_data.last_modified.to_s.colorize(:light_red)],
          ['Line Count'.colorize(:cyan), file_data.line_count.to_s.colorize(:green)],
          ['Word Count'.colorize(:cyan), file_data.word_count.to_s.colorize(:yellow)],
          ['Character Count'.colorize(:cyan), file_data.char_count.to_s.colorize(:magenta)],
          ['Is Empty'.colorize(:cyan), (file_data.is_empty ? 'Yes'.colorize(:red) : 'No'.colorize(:green))]
        ]
      )

      puts table.render(:ascii)
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
      @all_file_data = []
      files.each do |file|
        if File.file?(file) # Ensure it's a file and not a directory TODO: will it be bale to handle directories?
          puts "#{file} - Setting file data"
          file_data = FileData.new(file:)
          file_data.set_attributes
          FileDataPresenter.display(file_data:)
          @all_file_data << file_data
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
