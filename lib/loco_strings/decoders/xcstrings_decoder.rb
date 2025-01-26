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
        translatable = value.fetch("shouldTranslate", true)
        val = decode_string(key, value, @language)
        @strings[key] = val if val
        @strings[key] = LocoString.new(key, key, value["comment"], "new") if val.nil?
        @strings[key].translatable = translatable

        decode_translations(key, value)
      end
    end

    def decode_string(key, value, language)
      return unless value.key?("localizations")

      loc = value.dig("localizations", language)
      return if loc.nil?

      if loc.key?("stringUnit")
        decode_string_unit(key, loc, value["comment"])
      elsif loc.key?("variations")
        decode_variations(key, loc, value["comment"])
      end
    end

    def decode_string_unit(key, value, comment)
      return nil unless value.key?("stringUnit")

      unit = value["stringUnit"]
      translation = unit["value"]
      LocoString.new(key, translation, comment, unit["state"]) unless translation.nil?
    end

    def decode_variations(key, value, comment)
      variations = value["variations"]
      plural = decode_plural(variations, comment)
      return nil if plural.empty?

      variation = LocoVariantions.new(key, nil, comment)
      plural.each do |unit|
        variation.append_string(unit)
      end
      variation
    end

    def decode_plural(variation, comment)
      plural = variation["plural"]
      return [] if plural.nil?

      result = []
      plural.each do |key, value|
        unit = decode_string_unit(key, value, comment)
        result << unit unless unit.nil?
      end
      result
    end

    def decode_translations(key, value)
      @languages.each do |language|
        string = decode_string(key, value, language)
        @translations[language] ||= {}
        @translations[language][key] = string
      end
    end
  end
end
