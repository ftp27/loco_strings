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

      json = {
        "sourceLanguage" => @language,
        "strings" => {},
        "version" => "1.0"
      }
      generate_keys.each do |key|
        json["strings"][key] = encode_key(key)
      end
      JSON.pretty_generate(json, { space_before: " " })
    end

    private

    def generate_keys
      keys = []
      @translations.each do |_, translation|
        keys += translation.keys
      end
      keys.uniq
    end

    def encode_key(key)
      row = {}
      sorted_keys.each do |language|
        process_language(row, language, key)
      end
      row
    end

    def sorted_keys
      @translations.keys.sort_by(&:to_s)
    end

    def process_language(row, language, key)
      return unless @translations[language].key?(key)

      value = @translations[language][key]
      return if value.nil?

      add_comment(row, value)
      add_localization(row, language, value)
      add_translation_flag(row, value)
    end

    def add_comment(row, value)
      row["comment"] = value.comment unless row.key?("comment") || value.comment.nil?
    end

    def add_localization(row, language, value)
      row["localizations"] ||= {}
      row["localizations"][language] = encode_value(value)
    end

    def add_translation_flag(row, value)
      row["shouldTranslate"] = false if value.translatable == false
    end

    def encode_value(value)
      if value.is_a?(LocoVariantions)
        encode_variations(value)
      else
        encode_string_unit(value)
      end
    end

    def encode_string_unit(unit)
      res = { "stringUnit" => {} }
      res["stringUnit"]["state"] = if unit.state.nil?
                                     "new"
                                   else
                                     unit.state
                                   end
      res["stringUnit"]["value"] = unit.value
      res
    end

    def encode_variations(variations)
      plural = {}
      variations.strings.each do |key, string|
        plural[key] = encode_string_unit(string) unless string.nil?
      end
      {
        "variations" => {
          "plural" => plural
        }
      }
    end
  end
end
