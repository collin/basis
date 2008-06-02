module Basis
  class Reportable < StandardError; end
    
  class DirectoryNotFound < Reportable
    def initialize(directory)
      super("#{directory} doesn't exist")
    end
  end

  class UnknownScheme < Reportable
    def initialize(url)
      super("Unknown URL scheme: #{url}")
    end
  end
end
