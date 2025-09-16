module FatModelFinder
  class FileData
    attr_accessor :line_count, :file_name, :file_size, :file_extension, :last_modified, :word_count, :char_count,
                  :is_empty, :file, :method_count, :callback_count, :association_count, :validation_count

    def initialize(file:)
      @file = file
      @method_count = nil
      @callback_count = nil
      @association_count = nil
      @validation_count = nil
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
        validation_count: @validation_count
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

    # TODO: find the longest method...

    # TODO: calculate what is a fat model and what is not...
  end
end
