require_relative 'base_mapper'

module Mongobzar
  module Mapping
    class EmbeddedMapper
      include BaseMapper

      def build_embedded_dto(domain_object)
        return nil unless domain_object
        build_dto(domain_object)
      end

      def build_domain_object(dto)
        return nil unless dto
        domain_object = build_new(dto)
        build_domain_object!(domain_object, dto)
        domain_object
      end

      def build_domain_object!(domain_object, dto)
      end

      #TODO:
      # add build_domain_object! for consistency

      def build_embedded_collection(domain_objects)
        dtos = []
        domain_objects.each do |domain_object|
          dtos << build_embedded_dto(domain_object)
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
