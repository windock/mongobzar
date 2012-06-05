require_relative 'base_mapper'

module Mongobzar
  module Mapping
    class BaseMapperWithIdentity < BaseMapper
      def build_dto(domain_object)
        dto = super
        add_identity_to_dto!(dto)
        dto
      end

      def add_identity_to_dto!(dto)
        dto['_id'] = BSON::ObjectId.new
      end

      def build_domain_object(dto)
        domain_object = build_new(dto)
        domain_object.id = dto['_id']
        build_domain_object!(domain_object, dto)
        domain_object
      end

      def build_domain_object!(domain_object, dto)
      end
    end
  end
end
