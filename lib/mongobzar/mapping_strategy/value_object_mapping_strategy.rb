module Mongobzar
  module MappingStrategy
    class ValueObjectMappingStrategy
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

      def build_domain_object(dto)
        return nil unless dto
        domain_object = build_new(dto)
        build_domain_object!(domain_object, dto)
        domain_object
      end

      def build_domain_object!(domain_object, dto)
      end

      def build_dto(domain_object)
        return nil unless domain_object
        dto = {}
        build_dto!(dto, domain_object)
        dto
      end

      def build_dto!(dto, domain_object)
      end

      def update_dto(dto, domain_object)
        return nil unless domain_object
        update_dto!(dto, domain_object)
        dto
      end

      def update_dto!(dto, domain_object)
        build_dto!(dto, domain_object)
      end
    end
  end
end