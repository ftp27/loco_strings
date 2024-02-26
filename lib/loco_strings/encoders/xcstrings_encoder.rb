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
      @translations.each do |language, translation|
        next unless translation.key?(key)

        value = translation[key]
        next if value.nil?

        row["comment"] = value.comment unless row.key?("comment") || value.comment.nil?
        row["localizations"] ||= {}
        row["localizations"][language] = encode_value(value)
      end
      row
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
