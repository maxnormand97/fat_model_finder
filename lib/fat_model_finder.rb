# frozen_string_literal: true

require "thor"
require_relative "fat_model_finder/version"

module FatModelFinder
  class Error < StandardError; end

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
      files.each do |file|
        if File.file?(file) # Ensure it's a file and not a directory
          line_count = File.foreach(file).count
          puts "#{file} - #{line_count} lines"
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
  # BONUS it will provide some kind of text or html output
end
