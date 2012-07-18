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

      def update_dto!(dto, domain_object)
        mapper.update_dto!(dto, domain_object)
      end

      def build_dto!(dto, domain_object)
        mapper.build_dto!(dto, domain_object)
      end

      def build_domain_object!(domain_object, dto)
        mapper.build_domain_object!(domain_object, dto)
      end

      #TEST_ME
      def link_domain_object(domain_object, dto)
        domain_object.id = dto['_id']
      end

      protected
        attr_reader :mapper
    end
  end
end
