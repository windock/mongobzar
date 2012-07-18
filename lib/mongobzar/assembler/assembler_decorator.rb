require 'mongobzar/assembler/assembler'

module Mongobzar
  module Assembler
    class AssemblerDecorator < Assembler
      def initialize(assembler=Assembler.new)
        @assembler = assembler
      end

      def build_new(dto)
        assembler.build_new(dto)
      end

      def update_dto!(dto, domain_object)
        assembler.update_dto!(dto, domain_object)
      end

      def build_dto!(dto, domain_object)
        assembler.build_dto!(dto, domain_object)
      end

      def build_domain_object!(domain_object, dto)
        assembler.build_domain_object!(domain_object, dto)
      end

      #TEST_ME
      def link_domain_object(domain_object, dto)
        domain_object.id = dto['_id']
      end

      protected
        attr_reader :assembler
    end
  end
end
