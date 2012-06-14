require 'bson'

module Mongobzar
  class BSONIdGenerator
    def next_id
      BSON::ObjectId.new
    end
  end
end
