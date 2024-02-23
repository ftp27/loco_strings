# frozen_string_literal: true

require "json"

module LocoStrings
  # The XCStringsDecoder class is responsible for decoding the XCStrings file format.
  class XCStringsDecoder
    attr_reader :language, :strings, :translations, :languages

    def initialize(file_path)
      @file_path = file_path
      @strings = {}
      @translations = {}
      @languages = []
      @language = nil
    end

    def decode
      return @strings unless File.exist?(@file_path)

      file = File.read(@file_path)
      json = JSON.parse(file)
      extract_languages(json)
      @language = json["sourceLanguage"]
      decode_strings(json)
      @strings
    end

    private

    def extract_languages(json)
      @languages = []
      json["strings"].each do |_key, value|
        next unless value.key?("localizations")

        value["localizations"].each do |lang, _loc|
          @languages << lang
        end
      end
      @languages.uniq!
    end

    def decode_strings(json)
      strings = json["strings"]
      strings.each do |key, value|
        decode_string(key, value)
        decode_translations(key, value)
      end
    end

    def decode_string(key, value)
      comment = value["comment"]
      translation = key
      loc = value.dig("localizations", @language)
      translation = loc.dig("stringUnit", "value") unless loc.nil?
      @strings[key] = LocoString.new(key, translation, comment) unless translation.nil?
    end

    def decode_translations(key, value)
      @languages.each do |language|
        next unless value.dig("localizations", language, "stringUnit", "value")

        translation = value.dig("localizations", language, "stringUnit", "value")
        @translations[language] ||= {}
        @translations[language][key] = translation
      end
    end
  end
end
