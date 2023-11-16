# frozen_string_literal: true

module LocoStrings
  # LocoFile is a class for working with localization strings.
  class LocoFile
    attr_reader :file_path

    def initialize(file_path)
      @file_path = file_path
      clean
    end

    def read
      raise Error, "Not implemented"
    end

    def write
      raise Error, "Not implemented"
    end

    def update_file_path(file_path)
      @file_path = file_path
    end

    def update(key, value, comment = nil)
      if comment.nil? && @strings.has_key?(key)
        comment = @strings[key].comment 
      end
      @strings[key] = LocoString.new key, value, comment
    end

    def delete(key)
      @strings.delete key
    end

    def value(key)
      @strings[key]
    end

    def clean
      @strings = {}
    end
  end
end
