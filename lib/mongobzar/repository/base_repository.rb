module Mongobzar
  module Repository
    class BaseRepository
      def initialize(database_name, mongo_collection_name)
        @database_name = database_name
        @mongo_collection_name = mongo_collection_name
      end

      attr_accessor :assembler

      def clear_everything!
        mongo_collection.remove
      end

      protected
        attr_reader :mongo_collection_name

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
