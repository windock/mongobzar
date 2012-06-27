require_relative 'base_mapper'
require_relative 'has_identity'
require_relative 'dependent_with_identity'
require_relative 'with_identity_mapping_strategy'

module Mongobzar
  module Mapping
    class EmbeddedWithIdentityMapper
      include BaseMapper
      include DependentWithIdentity

      def build_dto(domain_object)
        mapping_strategy.build_dto(domain_object)
      end

      def build_dto!(dto, domain_object)
        mapping_strategy.build_dto!(dto, domain_object)
      end

      def build_domain_object(dto)
        mapping_strategy.build_domain_object(dto)
      end

      def update_dto(dto, domain_object)
        mapping_strategy.update_dto(dto, domain_object)
      end

      def build_dtos(domain_objects)
        dict, dtos = build_dtos_collection(domain_objects)
        dict.each do |domain_object, dto|
          mapping_strategy.link_domain_object(domain_object, dto)
        end
        dict.values
      end

      def update_dtos(dtos, domain_objects)
        dict = update_dtos_collection(dtos, domain_objects)
        dict.each do |domain_object, dto|
          mapping_strategy.link_domain_object(domain_object, dto)
        end
        dict.values
      end
    end
  end
end
