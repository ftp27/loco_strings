module LocoStrings
  class LocoFile 
    def initialize(file_path) 
      @file_path = file_path
      @strings = {}
    end

    def read
      raise Error, "Not implemented"
    end

    def write 
      raise Error, "Not implemented"
    end

    def update_file_path(file_path)
      @file_path = file_path
    end

    def get_file_path
      @file_path
    end

    def update(key, value, comment = nil)
      @strings[key] = LocoString.new key, value, comment
    end

    def delete(key)
      @strings.delete key
    end

    def value(key)
      @strings[key]
    end
  end
end