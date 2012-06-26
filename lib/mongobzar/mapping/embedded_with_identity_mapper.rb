require_relative 'base_mapper'
require_relative 'has_identity'
require_relative 'dependent_with_identity'

module Mongobzar
  module Mapping
    class EmbeddedWithIdentityMapper
      include BaseMapper
      include HasIdentity
      include DependentWithIdentity

      def build_dto(domain_object)
        return nil unless domain_object
        dto = super
        domain_object.id = dto['_id']
        dto
      end

      def update_embedded_dto(dto, domain_object)
        return nil unless domain_object
        update_dto!(dto, domain_object)
        dto
      end

      def build_dtos(domain_objects)
        dict, dtos = build_dtos_collection(domain_objects)
        dict.each do |domain_object, dto|
          link_domain_object(domain_object, dto)
        end
        dict.values
      end

      def update_embedded_collection(dtos, domain_objects)
        dict = update_dtos_collection(dtos, domain_objects)
        dict.each do |domain_object, dto|
          link_domain_object(domain_object, dto)
        end
        dict.values
      end
    end
  end
end
