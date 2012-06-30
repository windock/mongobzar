module Mongobzar
  module Mapping
    module BaseMapper
      def initialize(database_name)
        @connection = Mongo::Connection.new
        @db = @connection.db(database_name)
        @database_name = database_name
        @mongo_collection = @db.collection(mongo_collection_name, safe: true)
      end

      def clear_everything!
        mongo_collection.remove
      end

      def build_domain_object(dto)
        mapping_strategy.build_domain_object(dto)
      end

      def build_new(dto)
        mapping_strategy.build_new(dto)
      end

      def build_dto(domain_object)
        mapping_strategy.build_dto(domain_object)
      end

      protected
        attr_reader :mongo_collection
        attr_reader :database_name
    end
  end
end
