# frozen_string_literal: true

# rubocop:disable Layout/LineLength
# rubocop:disable Metrics/BlockLength

RSpec.describe LocoStrings do
  it "has a version number" do
    expect(LocoStrings::VERSION).not_to be nil
  end

  describe ".load" do
    context "when file format is not supported" do
      it "raises an error" do
        expect do
          LocoStrings.load("spec/test_files/test_file.txt")
        end.to raise_error(LocoStrings::Error, "Unsupported file format: .txt")
      end
    end
    context "when file format is supported" do
      it "returns an instance of LocoFile" do
        expect(LocoStrings.load("spec/test_files/Localizable.strings")).to be_a(LocoStrings::LocoFile)
      end
      it "recognize iOS Strings" do
        expect(LocoStrings.load("spec/test_files/Localizable.strings")).to be_a(LocoStrings::IosFile)
      end
      it "recognize Android XML Strings" do
        expect(LocoStrings.load("spec/test_files/strings.xml")).to be_a(LocoStrings::AndroidFile)
      end
      it "returns path to file" do
        expect(LocoStrings.load("spec/test_files/Localizable.strings").file_path).to eq("spec/test_files/Localizable.strings")
      end
      it "updates file path" do
        strings = LocoStrings.load("spec/test_files/Localizable.strings")
        strings.update_file_path("new_path")
        expect(strings.file_path).to eq("new_path")
      end
    end
    context "when strings changed" do
      it "udates value" do
        strings = LocoStrings.load("spec/test_files/Localizable.strings")
        strings.update("test_key_1", "new_value")
        expect(strings.value("test_key_1").value).to eq("new_value")
      end
      it "udates comment" do
        strings = LocoStrings.load("spec/test_files/Localizable.strings")
        strings.update("test_key_1", "new_value", "new_comment")
        expect(strings.value("test_key_1").comment).to eq("new_comment")
      end
      it "deletes key" do
        strings = LocoStrings.load("spec/test_files/Localizable.strings")
        strings.delete("test_key_1")
        expect(strings.value("test_key_1")).to be_nil
      end
    end
  end

  describe "IosFile" do
    it "reads strings from a strings file" do
      strings = LocoStrings.load("spec/test_files/Localizable.strings")
      expect(strings.read).to eq(
        "test_key_1" => LocoStrings::LocoString.new("test_key_1", "test_text_1"),
        "test_key_2" => LocoStrings::LocoString.new("test_key_2", "test_text_2", "test comment for key 2"),
        "test_key_3" => LocoStrings::LocoString.new("test_key_3", "test_text_3")
      )
    end
    it "doesn't fail if file is doent exist" do
      test_path = "spec/test_files/test.strings"
      File.delete(test_path) if File.exist?(test_path)
      strings = LocoStrings.load(test_path)
      expect(strings.read).to eq({})
    end
    it "makes strings file" do
      test_path = "spec/test_files/test.strings"
      File.delete(test_path) if File.exist?(test_path)
      strings = LocoStrings.load(test_path)
      strings.update("test_key_1", "test_text_1")
      strings.update("test_key_2", "test_text_2", "test comment for key 2")
      strings.write
      expect(File.exist?(test_path)).to be true
      expect(File.read(test_path)).to eq("\"test_key_1\" = \"test_text_1\";\n/* test comment for key 2 */\n\"test_key_2\" = \"test_text_2\";\n")
      File.delete(test_path) if File.exist?(test_path)
    end
    it "updates string in a file" do
      test_path = "spec/test_files/test.strings"
      test_strings = "\"test_key_1\" = \"test_text_1\";\n/* test comment for key 2 */\n\"test_key_2\" = \"test_text_2\";\n\"test_key_3\" = \"test_text_3\";\n"
      File.open(test_path, "w") { |file| file.write(test_strings) }
      strings = LocoStrings.load(test_path)
      strings.read
      strings.update("test_key_1", "test_text_1_updated")
      strings.write
      expect(File.read(test_path)).to eq("\"test_key_1\" = \"test_text_1_updated\";\n/* test comment for key 2 */\n\"test_key_2\" = \"test_text_2\";\n\"test_key_3\" = \"test_text_3\";\n")
      File.delete(test_path) if File.exist?(test_path)
    end
  end

  describe "AndroidFile" do
    it "reads strings from a strings file" do
      expect(LocoStrings.load("spec/test_files/strings.xml").read).to eq(
        "test_key_1" => LocoStrings::LocoString.new("test_key_1", "test_text_1"),
        "test_key_2" => LocoStrings::LocoString.new("test_key_2", "test_text_2", "test comment for key 2"),
        "test_key_3" => LocoStrings::LocoString.new("test_key_3", "test_text_3")
      )
    end
    it "doesn't fail if file is doent exist" do
      test_path = "spec/test_files/test.xml"
      File.delete(test_path) if File.exist?(test_path)
      strings = LocoStrings.load(test_path)
      expect(strings.read).to eq({})
    end
    it "makes strings file" do
      test_path = "spec/test_files/test.xml"
      File.delete(test_path) if File.exist?(test_path)
      strings = LocoStrings.load(test_path)
      strings.update("test_key_1", "test_text_1")
      strings.update("test_key_2", "test_text_2", "test comment for key 2")
      strings.write
      expect(File.exist?(test_path)).to be true
      expect(File.read(test_path)).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<resources>\n  <string name=\"test_key_1\">test_text_1</string>\n  <!--test comment for key 2-->\n  <string name=\"test_key_2\">test_text_2</string>\n</resources>\n")
      File.delete(test_path) if File.exist?(test_path)
    end
    it "updates string in a file" do
      test_path = "spec/test_files/test.xml"
      test_strings = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<resources>\n  <string name=\"test_key_1\">test_text_1</string>\n  <!--test comment for key 2-->\n  <string name=\"test_key_2\">test_text_2</string>\n  <string name=\"test_key_3\">test_text_3</string>\n</resources>\n"
      File.open(test_path, "w") { |file| file.write(test_strings) }
      strings = LocoStrings.load(test_path)
      strings.read
      strings.update("test_key_1", "test_text_1_updated")
      strings.write
      expect(File.read(test_path)).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<resources>\n  <string name=\"test_key_1\">test_text_1_updated</string>\n  <!--test comment for key 2-->\n  <string name=\"test_key_2\">test_text_2</string>\n  <string name=\"test_key_3\">test_text_3</string>\n</resources>\n")
      File.delete(test_path) if File.exist?(test_path)
    end
  end
end
# rubocop:enable Layout/LineLength
# rubocop:enable Metrics/BlockLength
