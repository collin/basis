module Basis
  class DirectoryNotFound < StandardError
    def initialize(directory)
      super("#{directory} doesn't exist")
    end
  end
end
