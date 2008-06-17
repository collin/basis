require File.expand_path("#{File.dirname(__FILE__)}/../helper")

require "fileutils"
require "pathname"
require "tmpdir"

require "basis/errors"
require "basis/repository"

describe Basis::Repository do
  before(:all) { @valid = File.join(Dir.tmpdir, "repository") }
  
  before :each do
    FileUtils.rm_rf(@valid)
    FileUtils.mkdir_p(@valid)
  end
  
  describe "#initialize" do
    it "succeeds with a valid path" do
      repo = Basis::Repository.new(@valid)
      repo.path.must == Pathname.new(@valid)
    end
    
    it "complains about a nonexistent path" do
      lambda {
        Basis::Repository.new(File.join(Dir.tmpdir, "norepository"))
      }.must raise_error(Basis::DirectoryNotFound)
    end
  end
end
