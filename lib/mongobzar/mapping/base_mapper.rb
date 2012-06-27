module Mongobzar
  module Mapping
    module BaseMapper
      def initialize(*args)
      end

      def build_new(dto)
        mapping_strategy.build_new(dto)
      end

      def build_dto(domain_object)
        mapping_strategy.build_dto(domain_object)
      end

      def build_dto!(dto, domain_object)
        mapping_strategy.build_dto!(dto, domain_object)
      end

      def update_dto!(dto, domain_object)
        mapping_strategy.update_dto!(dto, domain_object)
      end
    end
  end
end
