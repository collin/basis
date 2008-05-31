module Basis
  class Reportable < StandardError; end
    
  class DirectoryNotFound < Reportable
    def initialize(directory)
      super("#{directory} does not exist")
    end
  end

  class DirectoryAlreadyExists < Reportable
    def initialize(directory)
      super("#{directory} already exists")
    end
  end
  
  class UnknownScheme < Reportable
    def initialize(url)
      super("Unknown URL scheme: #{url}")
    end
  end
end
