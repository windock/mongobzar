require 'mongobzar/bson_id_generator'

module Mongobzar
  module MappingStrategy
    class EntityMappingStrategy
      def build_domain_object(dto)
        return nil if dto.nil?
        domain_object = build_new(dto)
        domain_object.id = dto['_id']
        build_domain_object!(domain_object, dto)
        domain_object
      end

      def build_domain_object!(domain_object, dto)
      end

      def build_dto(domain_object)
        return nil if domain_object.nil?
        dto = {}
        dto['_id'] = domain_object.id || id_generator.next_id
        build_dto!(dto, domain_object)
        dto
      end

      def build_dto!(dto, domain_object)
      end

      #TEST_ME
      def update_dto(dto, domain_object)
        return nil unless domain_object
        update_dto!(dto, domain_object)
        dto
      end

      #TEST_ME
      def update_dto!(dto, domain_object)
        build_dto!(dto, domain_object)
      end

      def link_domain_object(domain_object, dto)
        domain_object.id = dto['_id']
      end

      def id_generator
        @id_generator ||= BSONIdGenerator.new
      end

      attr_writer :id_generator

      def build_dtos(domain_objects)
        domain_objects.map do |domain_object|
          build_dto(domain_object)
        end
      end

      def build_domain_objects(dtos)
        dtos.map do |dto|
          build_domain_object(dto)
        end
      end
    end
  end
end

