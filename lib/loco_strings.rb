# frozen_string_literal: true

require_relative "loco_strings/version"
require_relative "loco_strings/parsers/android_file"
require_relative "loco_strings/parsers/ios_file"
require_relative "loco_strings/parsers/xcstrings_file"

# LocoStrings is a Ruby gem for working with iOS and Android localization strings.
module LocoStrings
  class Error < StandardError; end

  LocoString = Struct.new(:key, :value, :comment, :state) do
    def initialize(key, value, comment = nil, state = nil)
      super
    end

    def update(value, comment = nil, state = nil)
      self.value = value
      self.comment = comment unless comment.nil?
      self.state = state
    end

    def to_s
      "Key: #{key}, Value: #{value}, Comment: #{comment || "None"}, State: #{state || "None"}"
    end
  end

  LocoVariantions = Struct.new(:key, :strings, :comment) do
    def initialize(key, strings = nil, comment = nil)
      super
      self.strings = strings || {}
    end

    def append_string(string)
      strings[string.key] = string
    end

    def update_variant(key, value, comment = nil, state = nil)
      if strings.key? key
        strings[key].update(value, comment, state)
      else
        strings[key] = LocoString.new(key, value, comment, state)
      end
    end

    def to_s
      "Key: #{key}, Strings: #{strings}, Comment: #{comment || "None"}"
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
