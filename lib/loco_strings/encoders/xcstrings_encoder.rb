# frozen_string_literal: true

require "json"

module LocoStrings
  # The XCStringsEncoder class is responsible for encoding the LocoStrings data to the XCStrings format.
  class XCStringsEncoder
    attr_reader :language, :strings, :translations, :languages

    def initialize(strings, translations, languages, language)
      @strings = strings
      @translations = translations
      @languages = languages
      @language = language
    end

    def encode
      raise Error, "The base language is not defined" if @language.nil?

      json = {}
      json["sourceLanguage"] = @language
      json["strings"] = {}
      @strings.each do |key, value|
        json["strings"][key] = encode_row(key, value)
      end
      json["version"] = "1.0"
      JSON.pretty_generate(json)
    end

    private

    def encode_row(key, value)
      row = {}
      row["comment"] = value.comment unless value.comment.nil?
      localizations = encode_localizations(key, value)
      row["localizations"] = localizations unless localizations.empty?
      row
    end

    def encode_localizations(key, value)
      localizations = {}
      localizations[@language] = encode_row_language(value.value) if should_encode_localization?(value.value, key)
      @languages.each do |language|
        next if language == @language
        next unless should_encode_localization?(@translations[language][key], key)

        localizations[language] = encode_row_language(@translations[language][key])
      end
      localizations
    end

    def should_encode_localization?(value, key)
      value != key && !value.nil?
    end

    def encode_row_language(value)
      { "stringUnit" => { "state" => "translated", "value" => value } }
    end
  end
end
