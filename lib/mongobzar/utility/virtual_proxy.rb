module Mongobzar
  module Utility
    class VirtualProxy
      def initialize(loader)
        @loader = loader
      end

      def method_missing(name, *args)
        actual.send(name, *args)
      end

      private
        attr_reader :loader

        def actual
          @actual ||= loader.call
        end
    end
  end
end
