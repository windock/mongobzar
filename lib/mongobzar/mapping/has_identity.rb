require_relative '../bson_id_generator'

module Mongobzar
  module Mapping
    module HasIdentity
      def initialize(*args)
        @id_generator = BSONIdGenerator.new
      end

      def build_dto(domain_object)
        dto = super
        add_identity_to_dto!(dto)
        dto
      end

      attr_accessor :id_generator

      def add_identity_to_dto!(dto)
        dto['_id'] = @id_generator.next_id
      end

      def build_domain_object(dto)
        return nil unless dto
        domain_object = build_new(dto)
        domain_object.id = dto['_id']
        build_domain_object!(domain_object, dto)
        domain_object
      end

      def build_domain_object!(domain_object, dto)
      end

      protected
        def link_domain_object(domain_object, dto)
          domain_object.id = dto['_id']
        end
    end
  end
end
