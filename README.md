# LocoStrings

[![Gem Version](https://badge.fury.io/rb/loco_strings.svg)](https://badge.fury.io/rb/loco_strings)

LocoStrings is a Ruby gem that provides utilities for working with localization strings in iOS and Android applications.

If you're an iOS or Android developer, you know how important it is to properly localize your apps for different languages and regions. However, managing localization files can be a tedious and error-prone task, especially as your app grows and supports more languages.

That's where LocoStrings comes in. With LocoStrings, you can easily parse and manipulate localization strings in both iOS `.strings` and Android `strings.xml` formats, allowing you to automate common localization tasks and ensure the accuracy and consistency of your translations.

In this README, we'll show you how to install and use LocoStrings in your Ruby projects. Let's get started!

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add loco_strings

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install loco_strings

## Usage

LocoStrings is a Ruby gem that can be used to manage and manipulate strings in iOS and Android applications. It supports two file formats: iOS strings files and Android XML files. The gem provides a simple and intuitive API to read, write, update, and delete strings.

To use the gem in your project, you can install it by adding the following line to your Gemfile:

```ruby
gem 'loco_strings'
```

Then, run `bundle install` to install the gem.

After installing the gem, you can use the `load` method to load a strings file. The method takes one argument, which is the path to the strings file.

```ruby
strings = LocoStrings.load("path/to/strings/file")
```

You can then use the `read` method to read the strings from the file. The method returns a hash where the keys are the string keys and the values are instances of the `LocoString` class.

```ruby
strings_hash = strings.read
```

You can access the values in the hash using the keys.

```ruby
value = strings_hash["key"]
```

You can update a string by using the `update` method. The method takes two or three arguments: the key, the new value, and optionally a new comment.

```ruby
strings.update("key", "new value", "new comment")
```

You can delete a string by using the `delete` method. The method takes one argument, which is the key.

```ruby
strings.delete("key")
```

You can write the changes back to the file using the `write` method.

```ruby
strings.write
```

LocoStrings supports two file formats: iOS strings files and Android XML files. When you load a file, LocoStrings automatically detects the file format and returns an instance of the appropriate class: `IosFile` or `AndroidFile`.

Here is an example of how to use LocoStrings to manage an iOS strings file:

```ruby
strings = LocoStrings.load("path/to/Localizable.strings")
# Read the strings
strings_hash = strings.read
# Update a string
strings.update("key", "new value")
# Delete a string
strings.delete("key")
# Write the changes back to the file
strings.write
```

And here is an example of how to use LocoStrings to manage an Android XML file:

```ruby
strings = LocoStrings.load("path/to/strings.xml")
# Read the strings
strings_hash = strings.read
# Update a string
strings.update("key", "new value")
# Delete a string
strings.delete("key")
# Write the changes back to the file
strings.write
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/ftp27/loco_strings](). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ftp27/loco_strings/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LocoStrings project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ftp27/loco_strings/blob/master/CODE_OF_CONDUCT.md).
