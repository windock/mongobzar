module Mongobzar
  module Mapping
    module BaseMapper
      def initialize(*args)
      end

      def build_domain_object(dto)
        mapping_strategy.build_domain_object(dto)
      end

      def build_new(dto)
        mapping_strategy.build_new(dto)
      end

      def build_dto(domain_object)
        mapping_strategy.build_dto(domain_object)
      end

      def build_domain_objects(dtos)
        mapping_strategy.build_domain_objects(dtos)
      end
    end
  end
end
