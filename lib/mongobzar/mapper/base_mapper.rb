module Mongobzar
  module Mapper
    class BaseMapper
      def initialize(database_name)
        @database_name = database_name
      end

      def clear_everything!
        mongo_collection.remove
      end

      protected
        def mongo_collection
          @mongo_collection ||= db.collection(mongo_collection_name, safe: true)
        end

        def db
          @db ||= connection.db(database_name)
        end

        def connection
          @connection ||= Mongo::Connection.new
        end

        attr_reader :database_name
    end
  end
end
