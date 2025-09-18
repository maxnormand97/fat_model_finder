# frozen_string_literal: true

module FatModelFinder
  # Presentation helper methods to output fat model data
  # rubocop:disable Layout/LineLength
  class FileDataPresenter
    # rubocop:disable Metrics/AbcSize
    def self.display(file_data:)
      puts "File Name: #{file_data.file_name.colorize(:green)}"
      puts "File Size: #{file_data.file_size} bytes".colorize(:green)
      puts "File Extension: #{file_data.file_extension.colorize(:green)}"
      puts "Last Modified: #{file_data.last_modified.to_s.colorize(:green)}"

      puts "Line Count: #{colorize_threshold(file_data.line_count, FatModelFinder::FileData::LINE_COUNT_THRESHOLD)}"
      puts "Word Count: #{file_data.word_count.to_s.colorize(:green)}"
      puts "Character Count: #{file_data.char_count.to_s.colorize(:green)}"
      puts "Is Empty: #{file_data.is_empty ? "Yes".colorize(:red) : "No".colorize(:green)}"

      puts "Method Count: #{colorize_threshold(file_data.method_count, FatModelFinder::FileData::METHOD_THRESHOLD)}"
      puts "Callback Count: #{colorize_threshold(file_data.callback_count, FatModelFinder::FileData::CALLBACK_THRESHOLD)}"
      puts "Association Count: #{colorize_threshold(file_data.association_count, FatModelFinder::FileData::ASSOCIATION_THRESHOLD)}"
      puts "Validation Count: #{colorize_threshold(file_data.validation_count, FatModelFinder::FileData::VALIDATION_THRESHOLD)}"
      puts "\n"
    end
    # rubocop:enable Metrics/AbcSize

    def self.present_fat_model(json_data:)
      file_name = json_data["file_name"]
      fat_model_data = json_data["fat_model_data"] || {}

      file_name_message = "The model in file '#{file_name.colorize(:red)}' is considered fat due to the following issues:"

      breakdown = fat_model_data.select { |_key, value| value == true }
      breakdown_message = breakdown.map { |key, _| "- #{key.to_s.gsub("_", " ").capitalize}".colorize(:red) }.join("\n")

      puts "#{file_name_message}\n#{breakdown_message}\n\n"
    end

    def self.display_tips
      tips = <<~TIPS
        To address these issues:
        - Reduce the number of methods by moving business logic to service objects or concerns.
        - Minimize callbacks by using them sparingly and considering alternative patterns.
        - Simplify associations by ensuring they are necessary and not overly complex.
        - Break down validations into smaller, reusable components if possible.
        - If the line count is high, split the model into smaller, more focused classes.

        Remember, the goal is to keep your models focused and maintainable.
      TIPS

      puts tips
    end

    # Flag fat model conditions that have passed
    def self.colorize_threshold(value, threshold)
      value.to_i > threshold ? value.to_s.colorize(:red) + " - (LIMIT EXCEEDED)".colorize(:red) : value.to_s.colorize(:green)
    end
  end
  # rubocop:enable Layout/LineLength
end
