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

    def update(key, value, comment = nil, language = @language)
      raise Error, "The base language is not defined" if @language.nil?

      if @language == language
        update_with_same_language(key, value, comment)
      else
        update_with_different_language(key, value, comment, language)
      end
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

    def update_with_different_language(key, value, comment, language)
      @languages << language unless @languages.include?(language)
      @translations[language] ||= {}
      @translations[language][key] = value
      @strings[key] ||= LocoString.new(key, key, comment)
    end

    def update_with_same_language(key, value, comment)
      existing_comment = @strings[key]&.comment
      comment ||= existing_comment if existing_comment && @strings.key?(key)
      @strings[key] = LocoString.new(key, value, comment)
    end
  end
end
