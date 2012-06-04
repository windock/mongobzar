module Mongobzar
  module Test
    class Person
      attr_accessor :id
      attr_reader :addresses
      attr_accessor :work_address

      def initialize
        @addresses = []
      end

      def add_address(address)
        @addresses << address
      end

      def remove_address(address)
        @addresses.delete(address)
      end
    end
  end
end
