module Basis
  class Installer
    class Lifecycle
      attr_reader :installer

      def initialize(installer)
        @installer = installer
        @force = false
      end

      def install?(file)
        return true if @force || !file.exist?

        lambda do
          $stdout.print "#{file.relative_path_from(@installer.target)} exists, overwrite? [Ynaq] "
          $stdout.flush

          case $stdin.gets.chomp.downcase
            when "", "y" then true
            when "n"     then false
            when "a"     then @force = true
            when "q"     then exit(1)
            else redo
          end
        end.call
      end

      def installing(file)
      end

      def installed(file)
      end      
    end
  end
end
