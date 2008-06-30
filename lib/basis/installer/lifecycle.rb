module Basis
  class Installer
    class Lifecycle
      attr_reader :installer

      def initialize(installer)
        @installer = installer
        @force = false
      end

      # Called when installation starts. Nothing's happened yet.

      def starting
      end

      # Called when installation's complete, assuming nothing asploded.

      def finished
      end

      # Called to decide whether or not to install a target file. Default impl:
      # If the target <tt>destination</tt> doesn't exist or installation has been
      # forced, return true. Otherwise, ask the user to decide.

      def install?(destination)
        return true if @force || !destination.exist?

        lambda do
          $stdout.print "#{destination.relative_path_from(@installer.target)} exists, overwrite? [Ynaq] "
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

      # Called right before a file is installed.

      def installing(destination)
      end

      # Called right after a file is installed.

      def installed(destination)
      end
    end
  end
end
