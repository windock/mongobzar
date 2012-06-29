module Mongobzar
  module MappingStrategy
    class SimpleMappingStrategy
      def initialize(build_new, attribute_names=[])
        @build_new = build_new
        @method_names = attribute_names
      end

      def build_domain_object(dto)
        return nil if dto.nil?
        domain_object = @build_new.call(dto)
        @method_names.each do |method_name|
          dto_value = dto[method_name] || dto[method_name.to_s]
          domain_object.send(:"#{method_name}=", dto_value)
        end
        domain_object
      end

      def build_dto(domain_object)
        return nil if domain_object.nil?
        dto = {}
        @method_names.each do |method_name|
          dto[method_name] = domain_object.send(method_name)
        end

        dto
      end

      #TODO: update_dto, update_dto!
    end
  end
end
