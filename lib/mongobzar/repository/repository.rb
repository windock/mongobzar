require 'mongo'
require 'mongobzar/repository/document_not_found'
require 'mongobzar/repository/base_repository'

module Mongobzar
  module Repository
    class Repository < BaseRepository
      def all
        dtos = mongo_collection.find
        dtos.map do |dto|
          assembler.build_domain_object(dto)
        end
      end

      def find(id)
        assembler.build_domain_object(find_dto(id))
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

      def insert(obj)
        dto = assembler.build_dto(obj)
        insert_dto(dto)
        update_domain_object_after_insert(obj, dto)
      end

      def update_domain_object_after_insert(obj, dto)
        assembler.link_domain_object(obj, dto)
      end
      protected :update_domain_object_after_insert

      def update(obj)
        dto = find_dto(obj.id)
        assembler.update_dto(dto, obj)
        mongo_collection.update({ _id: dto['_id']}, dto)
      end

      def destroy(obj)
        mongo_collection.remove({ _id: obj.id })
      end
    end
  end
end
