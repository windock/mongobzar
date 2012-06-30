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

      def update_dto(dto, domain_object)
        mapping_strategy.update_dto(dto, domain_object)
      end

      def build_dtos(domain_objects)
        mapping_strategy.build_dtos(domain_objects)
      end

      def build_domain_objects(dtos)
        mapping_strategy.build_domain_objects(dtos)
      end

      def update_dtos(dtos, domain_objects)
        mapping_strategy.update_dtos(dtos, domain_objects)
      end

      def update_dto!(dto, domain_object)
        mapping_strategy.update_dto!(dto, domain_object)
      end
    end
  end
end
