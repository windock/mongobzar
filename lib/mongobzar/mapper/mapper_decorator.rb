require 'mongobzar/mapper/mapper'

module Mongobzar
  module Mapper
    class MapperDecorator < Mapper
      def initialize(mapper=Mapper.new)
        @mapper = mapper
      end

      def build_new(dto)
        mapper.build_new(dto)
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
        mapper.update_dto!(dto, domain_object)
      end

      def build_dto!(dto, domain_object)
        mapper.build_dto!(dto, domain_object)
      end

      def build_domain_object!(domain_object, dto)
        mapper.build_domain_object!(domain_object, dto)
      end

      protected
        attr_reader :mapper
    end
  end
end
