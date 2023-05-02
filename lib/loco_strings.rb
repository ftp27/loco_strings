# frozen_string_literal: true

require_relative "loco_strings/version"
require_relative "loco_strings/parsers/android_file"
require_relative "loco_strings/parsers/ios_file"

module LocoStrings
  class Error < StandardError; end

  LocoString = Struct.new(:key, :value, :comment) do
    def initialize(key, value, comment = nil); super end
  end

  def self.load(file_path)
    accepted_formats = [".strings", ".xml"]
    ext = File.extname(file_path)
    if !accepted_formats.include? ext
      raise Error, "Unsupported file format: #{ext}"
    end
    case ext
    when ".strings"
      IosFile.new file_path
    when ".xml"
      AndroidFile.new file_path
    else
      raise Error, "Not implemented"
    end
  end
end