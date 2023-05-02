# frozen_string_literal: true

require_relative "loco_file"

module LocoStrings
  # IosFile is a class for working with iOS localization strings.
  class IosFile < LocoFile
    def read
      clean
      return @strings unless File.exist?(@file_path)

      comment = nil
      file = File.read(@file_path)
      file.split("\n").each do |line|
        comment = extract_comment(line) || comment
        value = extract_string(line, comment)
        comment = nil if value
      end
      @strings
    end

    def write
      output = ""
      @strings.each do |key, value|
        output += "/* #{value.comment} */\n" if value.comment
        output += "\"#{key}\" = \"#{value.value}\";\n"
      end
      File.open(@file_path, "w") { |file| file.write(output) }
    end

    private

    def extract_comment(line)
      comment_match = line.match(%r{^/\*[\s\S]*?(.+)[\s\S]*?\*/$})
      comment_match[1].strip if comment_match
    end

    def extract_string(line, comment)
      value_match = line.match(/^"(.+)" = "(.+)";$/)
      return unless value_match

      name = value_match[1]
      value = value_match[2]
      @strings[name] = LocoString.new name, value, comment
      @strings[name]
    end
  end
end
