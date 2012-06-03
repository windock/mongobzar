require 'time'

module Mongobzar
  module Test
    class FakeClock
      def self.frozen
        clock = stub(:clock)
        now = Time.parse('2011-09-11T02:56')
        clock.stub!(:now) { now }
        clock
      end

      def self.different_frozen
        clock = stub(:clock)
        now = Time.parse('2012-09-11T02:56')
        clock.stub!(:now) { now }
        clock
      end

      def self.changes_year
        clock = stub(:clock)
        current_year = 2011
        now = Time.new(current_year)
        clock.stub!(:now) do
          current_year += 1
          Time.new(current_year)
        end
        clock
      end
    end
  end
end
