module Basis
  class Installer
    class Lifecycle
      attr_reader :installer

      def initialize(installer)
        @installer = installer
      end

      def install?(file)
        true # FIXME: user prompt on overwrite, etc
      end

      def installing(file)
      end

      def installed(file)
      end      
    end
  end
end
