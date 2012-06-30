require 'mongobzar/bson_id_generator'
require 'mongobzar/mapping/mapped_collection'

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

      #TEST_ME
      def build_dtos(domain_objects)
        dict, dtos = build_dtos_collection(domain_objects)
        dict.each do |domain_object, dto|
          link_domain_object(domain_object, dto)
        end
        dict.values
      end

      #TEST_ME
      def update_dtos(dtos, domain_objects)
        dict = update_dtos_collection(dtos, domain_objects)
        dict.each do |domain_object, dto|
          link_domain_object(domain_object, dto)
        end
        dict.values
      end

      #TEST_ME
      def build_domain_objects(dtos)
        mapped_collection = build_mapped_collection
        mapped_collection.load_dtos(dtos)
        mapped_collection.domain_objects
      end

      #TEST_ME
      def build_dtos_collection(domain_objects)
        mapped_collection = build_mapped_collection
        mapped_collection.load_domain_objects(domain_objects)
        dict = mapped_collection.dict
        dtos = dict.values
        [dict, dtos]
      end

      #TEST_ME
      def update_dtos_collection(dtos, domain_objects)
        mapped_collection = build_mapped_collection
        mapped_collection.load_dtos(dtos)
        mapped_collection.update(domain_objects)
        mapped_collection.dict
      end

      private
        def build_mapped_collection
          Mapping::MappedCollection.new(self)
        end
    end
  end
end

