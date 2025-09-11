module FatModelFinder
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
end
