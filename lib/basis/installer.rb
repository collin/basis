require "erb"
require "fileutils"
require "ostruct"
require "pathname"

require "basis/errors"
require "basis/installer/lifecycle"

module Basis
  class Installer
    attr_reader :lifecycle, :source, :target

    def initialize(source, target)
      @source = Pathname.new(source).freeze
      @target = Pathname.new(target).freeze

      raise Basis::DirectoryNotFound.new(@source) unless @source.directory?

      @lifecycle = create_or_load_lifecycle
    end

    def install(context={})
      Pathname.glob(@source + "**" + "*").each do |sourcepath|
        next unless sourcepath.file?
        next if /^basis/ =~ sourcepath.relative_path_from(@source)

        targetstr = sourcepath.relative_path_from(@source).expand_path(@target).to_s

        # valid: [identifier(.identifier ...)]
        targetstr.gsub!(/\[([a-z_][a-z0-9_]*(\.[a-z_][a-z0-9_]*)*)\]/i) do |match|
          propify(context, match)
        end

        targetpath = Pathname.new(targetstr)

        if @lifecycle.install?(targetpath)
          targetpath.dirname.mkpath
          @lifecycle.installing(targetpath)

          if erb?(sourcepath)
            targetpath.open("w") do |t|
              context = OpenStruct.new(context) if Hash === context
              erb = ERB.new(sourcepath.read)
              t.write(erb.result(context.instance_eval { binding }))
            end
          else
            FileUtils.copy(sourcepath, targetpath)
          end

          @lifecycle.installed(targetpath)
        end
      end
    end

    private

    def erb?(path)
      path.read =~ /<%.*%>/
    end

    # Apply a [dot.expression] to a target, which may be an object, a hash, or
    # any nesting thereof. Nils, unknown keys, and missing methods return the
    # original expression.

    def propify(target, expression)
      nodes = expression[1..-2].split(".").collect { |n| n.to_sym }

      nodes.inject(target) do |memo, node|
        (Hash === memo && memo[node]) || (memo.send(node) rescue expression)
      end
    end

    # If the source directory has a basis/lifecycle.rb file, load it in a protected
    # way, find the first constant that's < Basis::Installer::Lifecycle, and create
    # a new instance of it. If there's no lifecycle file, just create a new instance
    # of Basis::Installer::Lifecycle itself -- it's a no-op.

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
