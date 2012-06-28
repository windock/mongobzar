require_relative 'mapping_strategy'
require 'mongobzar/bson_id_generator'

module Mongobzar
  module Mapping
    class WithIdentityMappingStrategy < MappingStrategy

      def id_generator
        BSONIdGenerator.new
      end

      def build_dto(domain_object)
        return nil unless domain_object
        dto = super
        add_identity_to_dto!(dto)
        #FIXME: name of the method doesn't tell domain object gets changed
        link_domain_object(domain_object, dto)
        dto
      end

      def add_identity_to_dto!(dto)
        dto['_id'] = id_generator.next_id
      end

      def build_domain_object(dto)
        return nil unless dto
        domain_object = build_new(dto)
        link_domain_object(domain_object, dto)
        build_domain_object!(domain_object, dto)
        domain_object
      end

      def link_domain_object(domain_object, dto)
        domain_object.id = dto['_id']
      end
    end

  end
end
