require 'mongobzar/bson_id_generator'

module Mongobzar
  module MappingStrategy
    class WithIdentityMappingStrategy
      def initialize(mapping_strategy)
        @mapping_strategy = mapping_strategy
      end

      def build_domain_object(dto)
        return nil if dto.nil?
        #FIXME: yes, this doesn't really look like
        # simple decorator. Decorated object has dependency
        # of id being set, for DependenMapper, for example
        domain_object = @mapping_strategy.build_new(dto)
        domain_object.id = dto['_id']
        @mapping_strategy.build_domain_object!(domain_object, dto)
        domain_object
      end

      def build_dto(domain_object)
        return nil if domain_object.nil?
        domain_object.id = id_generator.next_id
        dto = @mapping_strategy.build_dto(domain_object)
        dto['_id'] = domain_object.id
        dto
      end

      def link_domain_object(domain_object, dto)
        domain_object.id = dto['_id']
      end

      def id_generator
        @id_generator ||= BSONIdGenerator.new
      end

      attr_writer :id_generator

      def method_missing(name, *args)
        @mapping_strategy.send(name, *args)
      end
    end
  end
end

