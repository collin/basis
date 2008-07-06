require "erb"
require "fileutils"
require "ostruct"
require "pathname"

require "basis/errors"
require "basis/installer/lifecycle"

module Basis
  class Installer
    attr_reader :lifecycle, :source, :target, :context

    LINK_REGEX = /\((.*)\)/

    def initialize(source, target)
      @source = Pathname.new(source).freeze
      @target = Pathname.new(target).freeze

      raise Basis::DirectoryNotFound.new(@source) unless @source.directory?

      @lifecycle = create_or_load_lifecycle
    end

    def install(kontext={})
      @context= kontext
      @lifecycle.starting
      install_files(file_glob)
      @lifecycle.finished
    end

    private
    
    def file_glob
      Pathname.glob(@source + "**" + "*")
    end

    def install_files(paths)
      paths.each do |path|
        next unless path.file?
        next if /^basis/ =~ path.relative_path_from(@source)

        install_file(path)
      end
    end

    def install_file(path)
      if_installing(path) do |target|
        unless_parsing_erb_for(target, path) do
          follow_link(target, path)
          copy_file(target, path)
        end
      end
    end

    def if_installing(path, &block)
      # valid: [identifier(.identifier ...)]
      target = determine_target(path)
      if @lifecycle.install?(target)
        @lifecycle.installing(target)
        path.dirname.mkpath
        yield(target)
        @lifecycle.installed(target)
      end
    end

    def determine_target(path)  
      target = path.relative_path_from(@source).expand_path(@target)
      target = interpolate(target)
      target = target_link(target)
      FileUtils.mkdir_p(target.dirname)
      target
    end

    def copy_file(target, path)
      FileUtils.copy(path, target) if path.file?
    end

    def unless_parsing_erb_for(target, path, &block)
      unless path.file? and erb?(path)
        yield
      else
        t = File.new(target, 'w') 
        context = OpenStruct.new(@context) if Hash === @context
        erb = ERB.new(path.read)
        t.write(erb.result(context.instance_eval { binding }))
        t.close
      end
    end

    def erb?(path)
      path.read =~ /<%.*%>/
    end

    # Apply a [dot.expression] to a target, which may be an object, a hash, or
    # any nesting thereof. Nils, unknown keys, and missing methods return the
    # original expression.

    def interpolate(path)
      path = path.to_s

      path.gsub!(/\[([a-z_][a-z0-9_]*(\.[a-z_][a-z0-9_]*)*)\]/i) do |match|
        nodes = match[1..-2].split(".").collect { |n| n.to_sym }

        nodes.inject(@context) do |memo, node|
          (Hash === memo && memo[node]) || (memo.send(node) rescue match)
        end
      end

      Pathname.new(path)
    end

    def target_link(path)
      if match = path.to_s.match(LINK_REGEX)
        link = match.captures.first.gsub('|', '/')
        linkpath = Pathname.new(link)
        path =  path.dirname + linkpath.basename
      end
      path
    end

    def follow_link(target, path)
      if match = path.to_s.match(LINK_REGEX)
        link = match.captures.first.gsub('|', '/')
        linkpath = Pathname.new(link).expand_path(@source)
        if linkpath.directory?
          self.class.new(linkpath, target).install(@context)
        end
      end
    end

    # If the source directory has a basis/lifecycle.rb file, load it in a protected
    # way, find the first constant that's < Basis::Installer::Lifecycle, and create
    # a new instance of it. If there's no lifecycle file or no subclass, just create
    # a new instance of the default lifecycle.

    def create_or_load_lifecycle
      lifecycle_path = (@source + "basis" + "lifecycle.rb")
      return Basis::Installer::Lifecycle.new(self) unless lifecycle_path.exist?

      anon = Module.new
      anon.class_eval(lifecycle_path.read)

      const = anon.constants.
        collect { |n| anon.const_get(n) }.
        detect  { |c| c < Basis::Installer::Lifecycle }

      (const || Basis::Installer::Lifecycle).new(self)
    end
  end
end
