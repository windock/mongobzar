require_relative 'mapped_collection'
require_relative 'base_mapper_with_identity'

module Mongobzar
  module Mapping
    class DependentMapper < BaseMapperWithIdentity
      def initialize(database_name)
        @connection = Mongo::Connection.new
        @db = @connection.db(database_name)
      end
      attr_accessor :foreign_key

      def insert_dependent_collection(parent, domain_objects)
        mapped_collection = build_mapped_collection
        mapped_collection.load_domain_objects(domain_objects)
        dict = mapped_collection.dict
        dtos = dict.values
        dtos.each do |dto|
          link_dto!(dto, parent)
        end

        dtos.each do |dto|
          mongo_collection.insert(dto)
        end
        dict.each do |domain_object, dto|
          update_domain_object_after_insert(domain_object, dto)
        end
      end

      def update_domain_object_after_insert(domain_object, dto)
        link_domain_object(domain_object, dto)
      end

      def update_dependent_collection(parent, domain_objects)
        mapped_collection = build_mapped_collection
        dtos = dependent_dtos_cursor(parent).to_a

        mapped_collection.load_dtos(dtos)
        mapped_collection.update(domain_objects)
        dict = mapped_collection.dict
        dtos = dict.values
        dtos.each do |dto|
          link_dto!(dto, parent)
        end

        remove_dependent_dtos(parent)
        dtos.each do |dto|
          mongo_collection.insert(dto)
        end
        dict.each do |domain_object, dto|
          update_domain_object_after_update(domain_object, dto)
        end
      end

      def update_domain_object_after_update(domain_object, dto)
        link_domain_object(domain_object, dto)
      end
      private :update_domain_object_after_update

      def link_domain_object(domain_object, dto)
        domain_object.id = dto['_id']
      end
      private :link_domain_object

      def find_dependent_collection(parent)
        mapped_collection = build_mapped_collection
        dtos = dependent_dtos_cursor(parent)
        mapped_collection.load_dtos(dtos)
        mapped_collection.domain_objects
      end

      def build_mapped_collection
        MappedCollection.new(self)
      end

      def set_mongo_collection(name)
        @mongo_collection = @db.collection(name, safe: true)
      end
      protected :set_mongo_collection

      def link_dto!(dto, owner_domain_object)
        dto[foreign_key] = owner_domain_object.id
      end

      def dependent_dtos_cursor(domain_object)
        mongo_collection.find(foreign_key => domain_object.id).to_a
      end
      protected :dependent_dtos_cursor

      def remove_dependent_dtos(domain_object)
        mongo_collection.remove(foreign_key => domain_object.id)
      end

      def clear_everything!
        mongo_collection.remove
      end

      protected
        attr_reader :mongo_collection
    end
  end
end
