# frozen_string_literal: true

# rubocop:disable Layout/LineLength

require_relative "lib/loco_strings/version"

Gem::Specification.new do |spec|
  spec.name = "loco_strings"
  spec.version = LocoStrings::VERSION
  spec.authors = ["Aleksei Cherepanov"]
  spec.email = ["ftp27host@gmail.com"]

  spec.summary = "LocoStrings is a Ruby gem for working with iOS and Android localization strings."
  spec.description = "LocoStrings is a powerful and easy-to-use Ruby gem that simplifies the process of managing localization strings for iOS and Android apps. With LocoStrings, you can easily extract, organize, and update your app's localized strings in one place, making it easy to maintain consistency across all of your app's translations. LocoStrings supports multiple file formats, including XLIFF and CSV, and provides a simple and intuitive API for working with your app's strings in code. Whether you're a solo developer or part of a team, LocoStrings makes managing your app's localization a breeze."
  spec.homepage = "https://github.com/ftp27/loco_strings"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "nokogiri", "~> 1.13", ">= 1.13.8"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

# rubocop:enable Layout/LineLength
