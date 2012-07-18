module Mongobzar
  module Assembler
    class PolymorphicAssembler
      def initialize(assemblers)
        @assemblers = assemblers
      end

      def build_domain_object(dto)
        assembler_for_dto(dto).build_domain_object(dto)
      end

      def build_dto(domain_object)
        assembler_for_domain_object(domain_object).build_dto(domain_object)
      end

      def build_dtos(domain_objects)
        domain_objects.map do |domain_object|
          assembler_for_domain_object(domain_object).build_dto(domain_object)
        end
      end

      def link_domain_object(domain_object, dto)
        assembler_for_domain_object(domain_object).link_domain_object(domain_object, dto)
      end

      def build_domain_objects(dtos)
        dtos.map do |dto|
          assembler_for_dto(dto).build_domain_object(dto)
        end
      end

      protected
        def assembler_for_dto(dto)
          assemblers.find { |assembler| assembler.type_code == dto['type'] }
        end

        def assembler_for_domain_object(domain_object)
          assemblers.find { |assembler| domain_object.kind_of?(assembler.domain_object_class) }
        end

      private
        attr_reader :assemblers
    end
  end
end
