require 'mongobzar/utility/mapped_collection'
require 'mongobzar/repository/base_repository'

module Mongobzar
  module Repository
    class DependentRepository < BaseRepository
      attr_accessor :foreign_key

      def insert_dependent_collection(parent, objs)
        dtos = build_dtos_and_link(parent, objs)
        insert_dtos(dtos)
      end

      def update_dependent_collection(parent, objs)
        remove_dependent_dtos(parent)

        dtos = build_dtos_and_link(parent, objs)
        insert_dtos(dtos)
      end

      def find_dependent_collection(parent)
        dtos = dependent_dtos_cursor(parent)
        assembler.build_domain_objects(dtos)
      end

      def dependent_dtos_cursor(obj)
        mongo_collection.find(foreign_key => obj.id).to_a
      end
      protected :dependent_dtos_cursor

      def remove_dependent_dtos(obj)
        mongo_collection.remove(foreign_key => obj.id)
      end

      def build_dtos_and_link(parent, objs)
        objs.map do |obj|
          dto = assembler.build_dto(obj)
          set_foreign_key!(dto, parent)
          assembler.link_domain_object(obj, dto)
          dto
        end
      end

      private

        def set_foreign_key!(dto, owner_obj)
          dto[foreign_key] = owner_obj.id
        end

        def insert_dtos(dtos)
          dtos.each do |dto|
            mongo_collection.insert(dto)
          end
        end

    end
  end
end
