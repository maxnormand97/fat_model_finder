# frozen_string_literal: true

require_relative "fat_model_finder/version"

module FatModelFinder
  class Error < StandardError; end
  # Your code goes here...

  # Fat model finder
  # It will scan a rails repo specifically in the /models dir
  # it will go through each file and count the amount of lines that file has
    # the output will be ordered highest to lowest
    # the bigger files will be flagged based on an average of the total line length
  # it provide a CLI output with links to the files flagged
  # BONUS it will provide some kind of text or html output
end
