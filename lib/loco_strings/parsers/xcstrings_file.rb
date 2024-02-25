# frozen_string_literal: true

require_relative "loco_file"
require_relative "../encoders/xcstrings_encoder"
require_relative "../decoders/xcstrings_decoder"
require "json"

module LocoStrings
  # The XCStringsFile class is responsible for reading and writing the XCStrings file format.
  class XCStringsFile < LocoFile
    def read
      clean
      return @strings unless File.exist?(@file_path)

      decoder = XCStringsDecoder.new(@file_path)
      decoder.decode

      @language = decoder.language
      @strings = decoder.strings
      @translations = decoder.translations
      @languages = decoder.languages
      @strings
    end

    def write
      raise Error, "The base language is not defined" if @language.nil?

      json = XCStringsEncoder.new(@strings, @translations, @languages, @language).encode
      File.write(@file_path, json)
    end

    def update(key, value, comment = nil, stage = nil, language = @language)
      raise Error, "The base language is not defined" if @language.nil?

      stage = "translated" if stage.nil?
      string = make_strings(key, value, comment, stage, language)
      return if string.nil?

      @translations[language] ||= {}
      @translations[language][key] = string
      @strings[key] = string if @language == language
    end

    def update_variation(key, variant, strings, comment = nil, state = nil, language = @language) # rubocop:disable Metrics/ParameterLists
      raise Error, "The base language is not defined" if @language.nil?

      variations = make_variations(key, variant, strings, comment, state, language)
      return if variations.nil?

      @translations[language] ||= {}
      @translations[language][key] = variations
      @strings[key] = variations if @language == language
    end

    def select_language(language)
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

    def clean
      @strings = {}
      @translations = {}
      @languages = []
      @language = nil
    end

    private

    def make_strings(key, value, comment = nil, state = nil, language = @language)
      unit = @translations.dig(language, key)
      return LocoString.new(key, value, comment, state) if unit.nil?

      if unit.is_a?(LocoVariantions)
        puts "Variations not supported through this method"
        return nil
      end
      unit.update(value, comment, state)
      unit
    end

    def make_variations(key, variant, value, comment = nil, state = nil, language = @language) # rubocop:disable Metrics/ParameterLists
      variants = @translations.dig(language, key)

      return make_strings(key, value, comment, state, language) if variants.is_a?(LocoString)

      if variants.nil?
        state = "new" if state.nil?
        return LocoVariantions.new(key, { variant => LocoString.new(variant, value, comment, state) })
      end

      variants.update_variant(variant, value, comment, state)
      variants
    end
  end
end
