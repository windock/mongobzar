module Mongobzar
  module Assembler
    class Assembler

      def build_domain_object!(obj, dto)
      end

      def build_dto!(dto, obj)
      end

      def build_domain_object(dto)
        return nil unless dto
        obj = build_new(dto)
        build_domain_object!(obj, dto)
        obj
      end

      def build_dto(obj)
        return nil unless obj
        dto = {}
        build_dto!(dto, obj)
        dto
      end

      def update_dto(dto, obj)
        return nil unless obj
        update_dto!(dto, obj)
        dto
      end

      def update_dto!(dto, obj)
        build_dto!(dto, obj)
      end

      def build_dtos(objs)
        objs.map { |obj| build_dto(obj) }
      end

      def build_domain_objects(dtos)
        dtos.map { |dto| build_domain_object(dto) }
      end

    end
  end
end
