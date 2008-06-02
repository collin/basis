require File.expand_path("#{File.dirname(__FILE__)}/../helper")

require "fileutils"
require "pathname"
require "tmpdir"

require "basis/installer"

describe Basis::Installer do
  before :each do
    @static = Pathname.new(File.join(FIXTURES_PATH, "static"))
    @target = Pathname.new(File.join(Dir.tmpdir, "destination"))
    
    FileUtils.rm_rf(@target)

    @installer = Basis::Installer.new(@static, @target)
  end
  
  describe "#initialize" do
    it "initializes sanely" do
      @installer.source.must == @static
      @installer.target.must == @target
    end
  
    it "complains when a source is not found" do
      lambda { Basis::Installer.new("nonexistent", @target) }.
        must raise_error(Basis::DirectoryNotFound)
    end
  end
  
  describe "#install" do
    before :each do
      @dynamic = Pathname.new(File.join(FIXTURES_PATH, "dynamic"))
      @erb = Pathname.new(File.join(FIXTURES_PATH, "erb"))
      @lifecycle = Pathname.new(File.join(FIXTURES_PATH, "lifecycle"))
      
      @dynamic_installer = Basis::Installer.new(@dynamic, @target)
      @erb_installer = Basis::Installer.new(@erb, @target)
      @lifecycle_installer = Basis::Installer.new(@lifecycle, @target)
    end
    
    it "copies files from the source to the target" do
      @installer.install
      (@target + "monkeys.txt").must be_exist
    end

    it "interpolates [file]" do
      @dynamic_installer.install(:file => "foo")
      (@target + "foo.txt").must be_exist
    end
    
    it "interpolates [nested.hash.keys]" do
      @dynamic_installer.install(:complex => {:nested => {:value => "foo"}})
      (@target + "foo.txt").must be_exist
    end
    
    it "interpolates [nested.method.calls]" do
      nested = Struct.new(:value).new("foo")
      @dynamic_installer.install(:complex => {:nested => nested})
      (@target + "foo.txt").must be_exist
    end
    
    it "interpolates [nested.keys.in.directory.names]" do
      @dynamic_installer.install(:directory => "foo")
      (@target + "foo/blank.txt").must be_exist
    end
    
    it "preserves invalid interpolations in file names" do
      @dynamic_installer.install
      (@target + "[invalid-].txt").must be_exist
    end
    
    it "preserves interpolations that are not in the context" do
      @dynamic_installer.install(Object.new)
      (@target + "[file].txt").must be_exist
    end
    
    it "render files via ERB with the context" do
      @erb_installer.install(valid_context)
      IO.read(@target + "simple.txt").must == "hai!"
    end
    
    it "render files via ERB with nested context expressions" do
      @erb_installer.install(valid_context)
      IO.read(@target + "nested.txt").must == "baz"
    end
    
    it "ignores all metadata files in source/basis" do
      @installer.install
      (@target + "basis" + "ignored.txt").must_not be_exist
    end
    
    it "respects the lifecycle when copying files" do
      @lifecycle_installer.install
      (@target + "nocopy.txt").must_not be_exist
      (@target + "copy.txt").must be_exist
    end
    
    it "pings the lifecycle on files that already exist" do
      @installer.install

      def (@installer.lifecycle).install?(file)
        raise RuntimeError if file.exist?
        true
      end
      
      (@target + "monkeys.txt").must be_exist
      lambda { @installer.install }.must raise_error(RuntimeError)
    end

    def valid_context
      { :greeting => "hai!", :foo => Struct.new(:bar).new("baz") } 
    end
  end
end
