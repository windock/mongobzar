module Mongobzar
  module Assembler
    class Assembler

      def build_domain_object!(domain_object, dto)
      end

      def build_dto!(dto, domain_object)
      end

      def build_domain_object(dto)
        return nil unless dto
        domain_object = build_new(dto)
        build_domain_object!(domain_object, dto)
        domain_object
      end

      def build_dto(domain_object)
        return nil unless domain_object
        dto = {}
        build_dto!(dto, domain_object)
        dto
      end

      def update_dto(dto, domain_object)
        return nil unless domain_object
        update_dto!(dto, domain_object)
        dto
      end

      def update_dto!(dto, domain_object)
        build_dto!(dto, domain_object)
      end

      def build_dtos(domain_objects)
        domain_objects.map { |obj| build_dto(obj) }
      end

      def build_domain_objects(dtos)
        dtos.map { |dto| build_domain_object(dto) }
      end

    end
  end
end
