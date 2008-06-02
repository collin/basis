module Basis
  class Installer
    class Lifecycle
      attr_reader :installer

      def initialize(installer)
        @installer = installer
        @force = false
      end
      
      # Called to decide whether or not to install a target file. Default impl:
      # If the target <tt>file</tt> doesn't exist or installation has been
      # forced, return true. Otherwise, ask the user to decide.

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

      # Called right before a target <tt>file</tt> is installed.

      def installing(file)
      end

      # Called right after a target <tt>file</tt> is installed.

      def installed(file)
      end      
    end
  end
end
