# frozen_string_literal: true

module FatModelFinder
  # Class to store attributes of file data, later to be parsed to JSON file for storage
  class FileData
    # TODO: we can have a method that overrides these rules and is configurable by the user later. These can just be
    # set as the default values...
    METHOD_THRESHOLD = 10
    CALLBACK_THRESHOLD = 5
    VALIDATION_THRESHOLD = 5
    ASSOCIATION_THRESHOLD = 5
    LINE_COUNT_THRESHOLD = 300

    attr_accessor :line_count, :file_name, :file_size, :file_extension, :last_modified, :word_count, :char_count,
                  :is_empty, :file, :method_count, :callback_count, :association_count, :validation_count, :fat,
                  :fat_model_data

    def initialize(file:)
      @file = file
      @method_count = nil
      @callback_count = nil
      @association_count = nil
      @validation_count = nil
      @fat = false
      @fat_model_data = {}
    end

    def set_base_attributes
      @line_count = File.foreach(@file).count
      @file_name = File.basename(@file)
      @file_size = File.size(@file)
      @file_extension = File.extname(@file)
      @last_modified = File.mtime(@file)
      @word_count = File.read(@file).split.size
      @char_count = File.read(@file).length
      @is_empty = File.zero?(@file)
    end

    # Convert the object to a hash for JSON serialization
    def to_h
      {
        file_name: @file_name,
        file_size: @file_size,
        file_extension: @file_extension,
        last_modified: @last_modified,
        line_count: @line_count,
        word_count: @word_count,
        char_count: @char_count,
        is_empty: @is_empty,
        method_count: @method_count,
        callback_count: @callback_count,
        association_count: @association_count,
        validation_count: @validation_count,
        fat: @fat,
        fat_model_data: @fat_model_data
      }
    end

    def count_methods
      file_content = File.read(@file)
      @method_count = file_content.scan(/^\s*def\s+/).size
    end

    def count_callbacks
      file_content = File.read(@file)
      # Match Active Record callbacks like before_save, after_create, etc.
      @callback_count = file_content.scan(/^\s*(before_|after_)\w+/).size
    end

    def count_associations
      file_content = File.read(@file)
      # Match Active Record associations like has_many, belongs_to, etc.
      @association_count = file_content.scan(/^\s*(has_many|has_one|belongs_to|has_and_belongs_to_many)/).size
    end

    def count_validations
      file_content = File.read(@file)
      # Match both `validates` and `validate` for validations
      @validation_count = file_content.scan(/^\s*(validates|validate)\b/).size
    end

    def calculate_if_fat_model
      @fat_model_data = {
        method_count_high: @method_count.to_i > METHOD_THRESHOLD,
        callback_count_high: @callback_count.to_i > CALLBACK_THRESHOLD,
        association_count_high: @association_count.to_i > ASSOCIATION_THRESHOLD,
        validation_count_high: @validation_count.to_i > VALIDATION_THRESHOLD,
        line_count_high: @line_count.to_i > LINE_COUNT_THRESHOLD
      }

      # A model is considered fat if greater than or eq to 2 of the conditions are true OR the line count is huge
      @fat = @fat_model_data.values.count(true) >= 2 || @fat_model_data[:line_count_high]
    end

    # TODO: find the longest method...
  end
end
