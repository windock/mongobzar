require 'time'

module Mongobzar
  module Test
    class FakeClock
      extend RR::Adapters::RRMethods

      def self.frozen
        clock = stub!
        now = Time.parse('2011-09-11T02:56')
        stub(clock).now() { now }
        clock
      end

      def self.different_frozen
        clock = stub!
        now = Time.parse('2012-09-11T02:56')
        stub(clock).now() { now }
        clock
      end

      def self.changes_year
        clock = stub!
        current_year = 2011
        now = Time.new(current_year)
        stub(clock).now() do
          current_year += 1
          Time.new(current_year)
        end
        clock
      end
    end
  end
end
