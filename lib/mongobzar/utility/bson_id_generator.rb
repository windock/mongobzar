require 'bson'

module Mongobzar
  module Utility
    class BSONIdGenerator
      def next_id
        BSON::ObjectId.new
      end
    end
  end
end
