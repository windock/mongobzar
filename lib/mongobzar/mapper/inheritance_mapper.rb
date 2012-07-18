require 'mongobzar/mapper/mapper_decorator'

module Mongobzar
  module Mapper
    class InheritanceMapper < MapperDecorator
      def initialize(domain_object_class, type_code, mapper=Mapper.new)
        @domain_object_class = domain_object_class
        @type_code = type_code
        super(mapper)
      end

      attr_reader :domain_object_class, :type_code
      attr_accessor :mapper

      def build_dto!(dto, domain_object)
        super
        dto['type'] = type_code
      end
    end
  end
end
