module Mongobzar
  module Mapping
    module PersistsToCollection
      def initialize(database_name)
        @connection = Mongo::Connection.new
        @db = @connection.db(database_name)
        @database_name = database_name
        @mongo_collection = @db.collection(mongo_collection_name, safe: true)
      end

      def clear_everything!
        mongo_collection.remove
      end

      protected
        attr_reader :mongo_collection
        attr_reader :database_name
    end
  end
end
