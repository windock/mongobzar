require 'mongobzar/mapping/mapped_collection'
require 'mongobzar/mapping/base_mapper'

module Mongobzar
  module Mapping
    class DependentMapper
      include BaseMapper

      attr_accessor :foreign_key

      def insert_dependent_collection(parent, domain_objects)
        dtos = build_dtos_and_link(parent, domain_objects)
        insert_dtos(dtos)
      end

      def update_dependent_collection(parent, domain_objects)
        remove_dependent_dtos(parent)

        dtos = build_dtos_and_link(parent, domain_objects)
        insert_dtos(dtos)
      end

      def find_dependent_collection(parent)
        dtos = dependent_dtos_cursor(parent)
        mapping_strategy.build_domain_objects(dtos)
      end

      def link_dto!(dto, owner_domain_object)
        dto[foreign_key] = owner_domain_object.id
      end
      private :link_dto!

      def dependent_dtos_cursor(domain_object)
        mongo_collection.find(foreign_key => domain_object.id).to_a
      end
      protected :dependent_dtos_cursor

      def remove_dependent_dtos(domain_object)
        mongo_collection.remove(foreign_key => domain_object.id)
      end

      def insert_dtos(dtos)
        dtos.each do |dto|
          mongo_collection.insert(dto)
        end
      end
      private :insert_dtos

      def build_dtos_and_link(parent, domain_objects)
        domain_objects.map do |domain_object|
          dto = mapping_strategy.build_dto(domain_object)
          link_dto!(dto, parent)
          mapping_strategy.link_domain_object(domain_object, dto)
          dto
        end
      end

    end
  end
end
