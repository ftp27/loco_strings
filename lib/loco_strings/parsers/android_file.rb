# frozen_string_literal: true

require_relative "loco_file"
require "nokogiri"

module LocoStrings
  # AndroidFile is a class for working with Android localization strings.
  class AndroidFile < LocoFile
    def read
      clean
      return @strings unless File.exist?(@file_path)

      comment = nil
      doc = Nokogiri::XML(File.open(@file_path))
      doc.xpath("//resources").first.children.each do |child|
        comment = extract_comment(child) || comment
        value = extract_string(child, comment)
        comment = nil if value
      end
      @strings
    end

    def write
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.resources do
          @strings.each do |key, value|
            xml.comment value.comment if value.comment
            xml.string(value.value, name: key)
          end
        end
      end
      File.open(@file_path, "w") { |file| file.write(builder.to_xml) }
    end

    private

    def extract_comment(child)
      child.text.strip if child.comment?
    end

    def extract_string(child, comment)
      return unless child.name == "string"

      name = child.attr("name")
      value = child.text
      @strings[name] = LocoString.new name, value, comment
      @strings[name]
    end
  end
end
