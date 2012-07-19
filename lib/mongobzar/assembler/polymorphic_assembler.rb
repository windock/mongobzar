module Mongobzar
  module Assembler
    class PolymorphicAssembler
      def initialize(assemblers)
        @assemblers = assemblers
      end

      def build_domain_object(dto)
        assembler_for_dto(dto).build_domain_object(dto)
      end

      def build_dto(obj)
        assembler_for_domain_object(obj).build_dto(obj)
      end

      def update_dto(dto, obj)
        assembler_for_domain_object(obj).update_dto(dto, obj)
      end

      def build_dtos(objs)
        objs.map do |obj|
          assembler_for_domain_object(obj).build_dto(obj)
        end
      end

      def link_domain_object(obj, dto)
        assembler_for_domain_object(obj).link_domain_object(obj, dto)
      end

      def build_domain_objects(dtos)
        dtos.map do |dto|
          assembler_for_dto(dto).build_domain_object(dto)
        end
      end

      protected
        def assembler_for_dto(dto)
          assemblers.find do |assembler|
            assembler.type_code == dto['type']
          end
        end

        def assembler_for_domain_object(obj)
          assemblers.find do |assembler|
            obj.kind_of?(assembler.domain_object_class)
          end
        end

      private
        attr_reader :assemblers
    end
  end
end
