module Basis
  class Installer
    class Lifecycle
      attr_reader :installer

      def initialize(installer)
        @installer = installer
      end

      def install?(path); true end

      def installing(path); end

      def installed(path); end
    end
  end
end
