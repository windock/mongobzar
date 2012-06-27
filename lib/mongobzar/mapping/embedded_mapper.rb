require_relative 'base_mapper'
require_relative 'mapping_strategy'

module Mongobzar
  module Mapping
    class EmbeddedMapper
      include BaseMapper

      def build_dto(domain_object)
        mapping_strategy.build_dto(domain_object)
      end

      def build_new(dto)
        mapping_strategy.build_new(dto)
      end

      def build_domain_object(dto)
        mapping_strategy.build_domain_object(dto)
      end

      def mapping_strategy
        MappingStrategy.new
      end

      def build_dtos(domain_objects)
        dtos = []
        domain_objects.each do |domain_object|
          dtos << build_dto(domain_object)
        end
        dtos
      end

      def build_domain_objects(dtos)
        domain_objects = []
        dtos.each do |dto|
          domain_objects << build_domain_object(dto)
        end
        domain_objects
      end
    end
  end
end
