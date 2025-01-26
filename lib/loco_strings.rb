# frozen_string_literal: true

require_relative "loco_strings/version"
require_relative "loco_strings/parsers/android_file"
require_relative "loco_strings/parsers/ios_file"
require_relative "loco_strings/parsers/xcstrings_file"

# LocoStrings is a Ruby gem for working with iOS and Android localization strings.
module LocoStrings
  class Error < StandardError; end

  LocoString = Struct.new(:key, :value, :comment, :state, :translatable) do
    def initialize(key, value, comment = nil, state = nil, translatable = nil)
      translatable = true if translatable.nil?
      super(key, value, comment, state, translatable)
    end

    def update(value, comment = nil, state = nil, translatable = nil)
      self.value = value
      self.comment = comment unless comment.nil?
      self.state = state
      self.translatable = translatable unless translatable.nil?
    end

    def to_s
      if translatable
        "Key: #{key}, Value: #{value}, Comment: #{comment || "None"}, " \
          "State: #{state || "None"}"
      else
        "Key: #{key}, Value: #{value}, Comment: #{comment || "None"}, " \
          "State: #{state || "None"}, Translatable: #{translatable}"
      end
    end
  end

  LocoVariantions = Struct.new(:key, :strings, :comment, :translatable) do
    def initialize(key, strings = nil, comment = nil, translatable = nil)
      super(key, strings || {}, comment, translatable || true)
    end

    def append_string(string)
      strings[string.key] = string
    end

    def update_variant(key, value, comment = nil, state = nil, translatable = nil)
      if strings.key? key
        strings[key].update(value, comment, state, translatable)
      else
        strings[key] = LocoString.new(key, value, comment, state, nil, translatable)
      end
    end

    def to_s
      if translatable
        "Key: #{key}, Strings: #{strings}, Comment: #{comment || "None"}"
      else
        "Key: #{key}, Strings: #{strings}, Comment: #{comment || "None"}, " \
          "Translatable: #{translatable}"
      end
    end
  end

  def self.load(file_path) # rubocop:disable Metrics/MethodLength
    ext = File.extname(file_path)
    raise Error, "Unsupported file format: #{ext}" unless [".strings", ".xml", ".xcstrings"].include? ext

    case ext
    when ".strings"
      IosFile.new file_path
    when ".xml"
      AndroidFile.new file_path
    when ".xcstrings"
      XCStringsFile.new file_path
    else
      raise Error, "Not implemented"
    end
  end
end
