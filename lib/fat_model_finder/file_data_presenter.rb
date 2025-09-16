module FatModelFinder
  class FileDataPresenter
    def self.display(file_data:)
      puts "File Name: #{file_data.file_name.colorize(:green)}"
      puts "File Size: #{file_data.file_size} bytes".colorize(:green)
      puts "File Extension: #{file_data.file_extension.colorize(:green)}"
      puts "Last Modified: #{file_data.last_modified.to_s.colorize(:green)}"
      puts "Line Count: #{file_data.line_count.to_s.colorize(:green)}"
      puts "Word Count: #{file_data.word_count.to_s.colorize(:green)}"
      puts "Character Count: #{file_data.char_count.to_s.colorize(:green)}"
      puts "Is Empty: #{file_data.is_empty ? 'Yes'.colorize(:red) : 'No'.colorize(:green)}"
      puts "Method Count: #{file_data.method_count.to_s.colorize(:green)}"
      puts "Callback Count: #{file_data.callback_count.to_s.colorize(:green)}"
      puts "Association Count: #{file_data.association_count.to_s.colorize(:green)}"
      puts "Validation Count: #{file_data.validation_count.to_s.colorize(:green)}"
    end
  end
end
