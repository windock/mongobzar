require 'mongobzar/assembler/assembler_decorator'

module Mongobzar
  module Assembler
    class InheritanceAssembler < AssemblerDecorator
      def initialize(domain_object_class, type_code, assembler=Assembler.new)
        @domain_object_class = domain_object_class
        @type_code = type_code
        super(assembler)
      end

      attr_reader :domain_object_class, :type_code
      attr_accessor :assembler

      def build_dto!(dto, domain_object)
        super
        dto['type'] = type_code
      end
    end
  end
end
