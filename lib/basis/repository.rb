require "pathname"

module Basis
  class Repository
    attr_reader :path
    
    def initialize(path="~/basis")
      @path = Pathname.new(path).freeze
      raise Basis::DirectoryNotFound.new(@path) unless @path.directory?
    end
  end
end
