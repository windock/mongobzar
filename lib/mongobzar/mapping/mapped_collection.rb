module Mongobzar
  module Mapping
    class MappedCollection
      def initialize(mapper)
        @updated = false
        @loaded_dtos = false
        @loaded_domain_objects = false
        @mapper = mapper
      end

      def load_dtos(dtos)
        @loaded_dtos = true
        @dtos = dtos
      end

      def update(domain_objects)
        @updated = true
        @domain_objects = domain_objects
      end

      def load_domain_objects(domain_objects)
        @loaded_domain_objects = true
        @domain_objects = domain_objects
      end

      def dict
        res = {}
        if @loaded_domain_objects
          @domain_objects.each do |domain_object|
            res[domain_object] = @mapper.build_dto(domain_object)
          end
        elsif @updated
          updated_pairs = {}
          @domain_objects.reject do |domain_object|
            domain_object.id.nil?
          end.each do |domain_object_with_id|
            dto = @dtos.detect { |dto| dto['_id'] == domain_object_with_id.id }
            @mapper.update_dto!(dto, domain_object_with_id)
            updated_pairs[domain_object_with_id] = dto
          end

          new_pairs = {}
          @domain_objects.select do |domain_object|
            domain_object.id.nil?
          end.each do |domain_object|
            dto = @mapper.build_dto(domain_object)
            new_pairs[domain_object] = dto
          end
          res = updated_pairs.merge(new_pairs)
        elsif @loaded_dtos
          @dtos.each do |dto|
            domain_object = @mapper.build_domain_object(dto)
            res[domain_object] = dto
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
    end
  end
end