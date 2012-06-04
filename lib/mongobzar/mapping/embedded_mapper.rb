module Mongobzar
  module Mapping
    class EmbeddedMapper
      def build_dto(domain_object)
        dto = {}
        build_dto!(dto, domain_object)
        dto
      end

      def build_dto!(dto, domain_object)
      end

      def build_embedded_dto(domain_object)
        return nil unless domain_object
        build_dto(domain_object)
      end

      def build_domain_object(dto)
        domain_object = build_new(dto)
      end
    end
  end
end
