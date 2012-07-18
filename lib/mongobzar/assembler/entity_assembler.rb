require 'mongobzar/utility/bson_id_generator'
require 'mongobzar/assembler/assembler_decorator'

module Mongobzar
  module Assembler
    class EntityAssembler < AssemblerDecorator
      def build_domain_object!(domain_object, dto)
        domain_object.id = dto['_id']
        super
      end

      def build_dto!(dto, domain_object)
        dto['_id'] = domain_object.id || id_generator.next_id
        super
      end

      def id_generator
        @id_generator ||= Utility::BSONIdGenerator.new
      end

      attr_writer :id_generator

      def link_domain_object(domain_object, dto)
        domain_object.id = dto['_id']
      end
    end
  end
end

