require 'mongobzar/assembler/value_object_assembler'

module Mongobzar
  module Assembler
    class SimpleAssembler < ValueObjectAssembler
      def initialize(build_new, attribute_names=[])
        @build_new = build_new
        @method_names = attribute_names
      end

      def build_domain_object(dto)
        return nil if dto.nil?
        obj = @build_new.call(dto)
        @method_names.each do |method_name|
          dto_value = dto[method_name] || dto[method_name.to_s]
          obj.send(:"#{method_name}=", dto_value)
        end
        obj
      end

      def build_dto(obj)
        return nil if obj.nil?
        dto = {}
        @method_names.each do |method_name|
          dto[method_name] = obj.send(method_name)
        end

        dto
      end

      #TODO: update_dto, update_dto!
    end
  end
end
