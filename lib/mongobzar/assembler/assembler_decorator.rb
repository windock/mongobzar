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

      def update_dto!(dto, obj)
        assembler.update_dto!(dto, obj)
      end

      def build_dto!(dto, obj)
        assembler.build_dto!(dto, obj)
      end

      def build_domain_object!(obj, dto)
        assembler.build_domain_object!(obj, dto)
      end

      #TEST_ME
      def link_domain_object(obj, dto)
        obj.id = dto['_id']
      end

      protected
        attr_reader :assembler
    end
  end
end
