require_relative "loco_file"
require "json"

module LocoStrings
  class XCStringsFile < LocoFile
    def initialize(file_path, language)
      @file_path = file_path
      @language = language
      clean
    end

    def read
      clean
      return @strings unless File.exist?(@file_path)

      comment = nil
      file = File.read(@file_path)
      json = JSON.parse(file)
      sourceLanguage = json["sourceLanguage"]
      strings = json["strings"]
      strings.each do |key, value|
        comment = value["comment"]
        translation = key unless @language != sourceLanguage
        if value.has_key?("localizations") && value["localizations"].has_key?(@language)
          loc = value["localizations"][@language]
        end
        translation = loc["stringUnit"]["value"] unless loc.nil?
        @strings[key] = LocoString.new key, translation, comment unless translation.nil?
      end
      @strings
    end

    def write(files = [])
      json = {}
      json["sourceLanguage"] = @language
      json["strings"] = {}
      @strings.each do |key, value|
        row = {}
        row["comment"] = value.comment unless value.comment.nil?
        localizations = {}
        if value.value != key && !value.value.nil?
          localizations[@language] = {
            "stringUnit" => {
              "state" => "translated",
              "value" => value.value
            }
          }
        end
        files.each do |file|
          translation = file.value(key)
          next unless translation

          next unless key != translation

          localizations[file.language] = {
            "stringUnit" => {
              "state" => "translated",
              "value" => translation
            }
          }
        end
        row["localizations"] = localizations unless localizations.empty?
        json["strings"][key] = row
      end
      json["version"] = "1.0"
      File.open(@file_path, "w") { |file| file.write(JSON.pretty_generate(json)) }
    end
  end
end
