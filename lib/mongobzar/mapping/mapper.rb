require 'mongo'
require_relative 'document_not_found'
require_relative 'base_mapper'
require_relative 'persists_to_collection'

module Mongobzar
  module Mapping
    class Mapper
      include BaseMapper
      include PersistsToCollection
      attr_accessor :id_generator

      def id_generator
        @id_generator ||= BSONIdGenerator.new
      end

      def build_dto(domain_object)
        dto = super
        add_identity_to_dto!(dto)
        dto
      end

      def add_identity_to_dto!(dto)
        dto['_id'] = id_generator.next_id
      end


      def all
        dtos = mongo_collection.find
        dtos.map do |dto|
          build_domain_object(dto)
        end
      end

      def find(id)
        build_domain_object(find_dto(id))
      end

      def find_dto(id)
        if id.kind_of?(String)
          id = BSON::ObjectId.from_string(id)
        end
        res = mongo_collection.find_one('_id' => id)
        raise DocumentNotFound unless res
        res
      end

      def insert_dto(dto)
        mongo_collection.insert(dto)
      end

      def insert(domain_object)
        dto = build_dto(domain_object)
        insert_dto(dto)
        update_domain_object_after_insert(domain_object, dto)
      end

      def update_domain_object_after_insert(domain_object, dto)
        domain_object.id = dto['_id']
      end
      protected :update_domain_object_after_insert

      def update(domain_object)
        dto = find_dto(domain_object.id)
        mapping_strategy.update_dto!(dto, domain_object)
        mongo_collection.update({ _id: dto['_id']}, dto)
      end

      def destroy(domain_object)
        mongo_collection.remove({ _id: domain_object.id })
      end
    end
  end
end
