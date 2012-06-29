require 'mongo'
require 'mongobzar/mapping/document_not_found'
require 'mongobzar/mapping/base_mapper'
require 'mongobzar/mapping/persists_to_collection'

module Mongobzar
  module Mapping
    class Mapper
      include BaseMapper
      include PersistsToCollection

      def all
        dtos = mongo_collection.find
        dtos.map do |dto|
          build_domain_object(dto)
        end
      end

      def find(id)
        mapping_strategy.build_domain_object(find_dto(id))
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
        mapping_strategy.link_domain_object(domain_object, dto)
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
