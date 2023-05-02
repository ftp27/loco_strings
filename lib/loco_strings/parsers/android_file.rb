require_relative "loco_file"
require 'nokogiri'

module LocoStrings
  class AndroidFile < LocoFile
    def read
      @strings = {}
      if !File.exist?(@file_path) 
        return @strings 
      end
      doc = Nokogiri::XML(File.open(@file_path))
      resources = doc.xpath('//resources').first
      children = resources.children
      index = 0
      while index < children.length
        child = children[index]
        if child.comment?
          comment = child.text.strip
        elsif child.name == 'string'
          name = child.attr('name')
          value = child.text
          @strings[child.attr('name')] = LocoString.new name, value, comment
          comment = nil
        end
        index += 1
      end
      @strings
    end

    def write
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.resources {
          @strings.each do |key, value|
            xml.comment value.comment if value.comment
            xml.string(value.value, name: key)
          end
        }
      end
      File.open(@file_path, 'w') { |file| file.write(builder.to_xml) }
    end
  end
end