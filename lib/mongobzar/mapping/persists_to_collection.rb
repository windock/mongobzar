module Mongobzar
  module Mapping
    module PersistsToCollection
      def initialize(database_name)
        super
        @connection = Mongo::Connection.new
        @db = @connection.db(database_name)
      end

      def clear_everything!
        mongo_collection.remove
      end

      protected
        attr_reader :mongo_collection

        def set_mongo_collection(name)
          @mongo_collection = @db.collection(name, safe: true)
        end
    end
  end
end
