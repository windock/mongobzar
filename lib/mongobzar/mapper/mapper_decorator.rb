require 'mongobzar/mapper/mapper'

module Mongobzar
  module Mapper
    class MapperDecorator < Mapper
      def initialize(mapper=nil)
        @mapper = mapper
      end

      def build_new(dto)
        if mapper
          mapper.build_new(dto)
        end
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

      def update_dto!(dto, domain_object)
        if mapper
          mapper.update_dto!(dto, domain_object)
        end
      end

      def build_dto!(dto, domain_object)
        if mapper
          mapper.build_dto!(dto, domain_object)
        end
      end

      def build_domain_object!(domain_object, dto)
        if mapper
          mapper.build_domain_object!(domain_object, dto)
        end
      end

      protected
        attr_reader :mapper
    end
  end
end
