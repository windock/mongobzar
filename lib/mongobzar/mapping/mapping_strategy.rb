module Mongobzar
  module Mapping
    class MappingStrategy
      def initialize(mapper)
        @mapper = mapper
      end

      def build_domain_object(dto)
        return nil unless dto
        domain_object = @mapper.build_new(dto)
        build_domain_object!(domain_object, dto)
        domain_object
      end

      def build_domain_object!(domain_object, dto)
      end
    end
  end
end
