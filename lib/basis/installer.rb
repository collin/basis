require "erb"
require "fileutils"
require "ostruct"
require "pathname"

require "basis/errors"

module Basis
  class Installer
    attr_reader :source, :target

    def initialize(source, target)
      @source = Pathname.new(source).freeze
      @target = Pathname.new(target).freeze
      
      raise Basis::DirectoryNotFound.new(@source) unless @source.directory?
      raise Basis::DirectoryAlreadyExists.new(@target) if @target.exist?
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
        targetpath.dirname.mkpath
        
        if erb?(sourcepath)
          targetpath.open("w") do |t|
            context = OpenStruct.new(context) if Hash === context
            erb = ERB.new(sourcepath.read)
            t.write(erb.result(context.instance_eval { binding }))
          end
        else
          FileUtils.copy(sourcepath, targetpath)
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
  end
end
