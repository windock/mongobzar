module Mongobzar
  module Utility
    class MappedCollection
      def initialize(assembler)
        @updated = false
        @loaded_dtos = false
        @loaded_objs = false
        @assembler = assembler
      end

      def load_dtos(dtos)
        @loaded_dtos = true
        @dtos = dtos
      end

      def update(objs)
        @updated = true
        @objs = objs
      end

      def load_domain_objects(objs)
        @loaded_objs = true
        @objs = objs
      end

      def dict
        res = {}
        if @loaded_objs
          @objs.each do |obj|
            res[obj] = assembler.build_dto(obj)
          end
        elsif @updated
          updated_pairs = {}
          @objs.reject do |obj|
            obj.id.nil?
          end.each do |obj_with_id|
            dto = @dtos.detect { |dto| dto['_id'] == obj_with_id.id }
            assembler.update_dto!(dto, obj_with_id)
            updated_pairs[obj_with_id] = dto
          end

          new_pairs = {}
          @objs.select do |obj|
            obj.id.nil?
          end.each do |obj|
            dto = assembler.build_dto(obj)
            new_pairs[obj] = dto
          end
          res = updated_pairs.merge(new_pairs)
        elsif @loaded_dtos
          @dtos.each do |dto|
            obj = assembler.build_domain_object(dto)
            res[obj] = dto
          end
        end
        res
      end

      def domain_objects
        dict.keys
      end

      def dtos
        dict.values
      end

      private
        attr_reader :assembler
    end
  end
end
