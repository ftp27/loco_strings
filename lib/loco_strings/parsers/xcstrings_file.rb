require_relative "loco_file"
require "json"

module LocoStrings
  class XCStringsFile < LocoFile
    def read
      clean
      return @strings unless File.exist?(@file_path)

      comment = nil
      file = File.read(@file_path)
      json = JSON.parse(file)
      extract_languages(json)
      @language = json["sourceLanguage"]
      @translations = {}
      strings = json["strings"]
      strings.each do |key, value|
        comment = value["comment"]
        translation = key
        if value.has_key?("localizations") && value["localizations"].has_key?(@language)
          loc = value["localizations"][@language]
        end
        translation = loc["stringUnit"]["value"] unless loc.nil?
        @strings[key] = LocoString.new key, translation, comment unless translation.nil?
        for language in @languages
          next unless value.has_key?("localizations") && value["localizations"].has_key?(language)

          loc = value["localizations"][language]
          translation = loc["stringUnit"]["value"] unless loc.nil?
          @translations[language] = {} unless @translations.has_key?(language)
          @translations[language][key] = translation unless translation.nil?
        end
      end
      @strings
    end

    def write
      raise Error, "The base language is not defined" if @language.nil?

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
        @languages.each do |language|
          next if language == @language
          next unless @translations.has_key?(language) && @translations[language].has_key?(key)

          localizations[language] = {
            "stringUnit" => {
              "state" => "translated",
              "value" => @translations[language][key]
            }
          }
        end
        row["localizations"] = localizations unless localizations.empty?
        json["strings"][key] = row
      end
      json["version"] = "1.0"
      File.open(@file_path, "w") { |file| file.write(JSON.pretty_generate(json)) }
    end

    def update(key, value, comment = nil, language = @language)
      raise Error, "The base language is not defined" if @language.nil?

      if @language != language
        @languages << language unless @languages.include?(language)
        @translations[language] = {} unless @translations.has_key?(language)
        @translations[language][key] = value
        @strings[key] = LocoString.new key, key, comment unless @strings.has_key?(key)
        return
      end
      comment = @strings[key].comment if @strings.has_key?(key) && (comment.nil? && @strings.has_key?(key))
      @strings[key] = LocoString.new key, value, comment
    end

    def value(key, language = nil)
      return @strings[key] if language.nil? || language == @language
      return @translations[language][key] if @translations.has_key?(language) && @translations[language].has_key?(key)
    end

    def clean
      @strings = {}
      @translations = {}
      @languages = []
      @language = nil
    end

    def set_language(language)
      raise Error, "The base language is aready defined" unless @language.nil?

      @language = language
    end

    def to_s
      result = ""
      result += "Base language: #{@language}\n" unless @language.nil?
      result += "Languages: #{@languages}\n" unless @languages.empty?
      result += "Strings:\n"
      @strings.each do |key, value|
        result += "#{key}: #{value}\n"
      end
      result
    end

    private

    def extract_languages(json)
      @languages = []
      json["strings"].each do |_key, value|
        next unless value.has_key?("localizations")

        value["localizations"].each do |lang, _loc|
          @languages << lang
        end
      end
      @languages.uniq!
    end
  end
end
