require_relative "loco_file"

module LocoStrings
  class IosFile < LocoFile
    def read
      @strings = {}
      if !File.exist?(@file_path) 
        return @strings 
      end
      strings_file = File.read(@file_path) 
      lines = strings_file.split("\n")
      index = 0 
      while index < lines.length
        line = lines[index]
        comment_match = line.match(/^\/\*[\s\S]*?(.+)[\s\S]*?\*\/$/)
        value_match = line.match(/^"(.+)" = "(.+)";$/)
        if comment_match 
          comment = comment_match[1].strip
        elsif value_match
          @strings[value_match[1]] = LocoString.new value_match[1], value_match[2], comment
          comment = nil
        end
        index += 1
      end
      @strings
    end

    def write
      output = ""
      @strings.each do |key, value|
        output += "/* #{value.comment} */\n" if value.comment
        output += "\"#{key}\" = \"#{value.value}\";\n"
      end
      File.open(@file_path, 'w') { |file| file.write(output) }
    end
  end
end