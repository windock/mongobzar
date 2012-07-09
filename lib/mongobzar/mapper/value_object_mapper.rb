require 'mongobzar/mapper/concrete_mapper'

module Mongobzar
  module Mapper
    class ValueObjectMapper < ConcreteMapper
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
    end
  end
end
