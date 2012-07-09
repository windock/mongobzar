require 'mongobzar/utility/bson_id_generator'
require 'mongobzar/mapper/concrete_mapper'

module Mongobzar
  module Mapper
    class EntityMapper < ConcreteMapper
      def build_domain_object(dto)
        return nil if dto.nil?
        domain_object = build_new(dto)
        domain_object.id = dto['_id']
        build_domain_object!(domain_object, dto)
        domain_object
      end

      def build_dto(domain_object)
        return nil if domain_object.nil?
        dto = {}
        dto['_id'] = domain_object.id || id_generator.next_id
        build_dto!(dto, domain_object)
        dto
      end

      def id_generator
        @id_generator ||= Utility::BSONIdGenerator.new
      end

      attr_writer :id_generator

      def link_domain_object(domain_object, dto)
        domain_object.id = dto['_id']
      end
    end
  end
end

