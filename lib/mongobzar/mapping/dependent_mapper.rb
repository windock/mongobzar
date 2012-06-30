require 'mongobzar/mapping/mapped_collection'
require 'mongobzar/mapping/base_mapper'
require 'mongobzar/mapping/persists_to_collection'

module Mongobzar
  module Mapping
    class DependentMapper
      include BaseMapper
      include PersistsToCollection

      attr_accessor :foreign_key

      def insert_dependent_collection(parent, domain_objects)
        dict, dtos = mapping_strategy.build_dtos_collection(domain_objects)

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
        mapping_strategy.link_domain_object(domain_object, dto)
      end

      def update_dependent_collection(parent, domain_objects)
        dtos = dependent_dtos_cursor(parent).to_a
        dict = mapping_strategy.update_dtos_collection(dtos, domain_objects)

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
        mapping_strategy.link_domain_object(domain_object, dto)
      end
      private :update_domain_object_after_update

      def find_dependent_collection(parent)
        dtos = dependent_dtos_cursor(parent)
        build_domain_objects(dtos)
      end

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

    end
  end
end
