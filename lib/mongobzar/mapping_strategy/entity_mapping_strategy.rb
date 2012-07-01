require 'mongobzar/bson_id_generator'
require 'mongobzar/mapping/mapped_collection'

module Mongobzar
  module MappingStrategy
    class EntityMappingStrategy
      def build_domain_object(dto)
        return nil if dto.nil?
        domain_object = build_new(dto)
        domain_object.id = dto['_id']
        build_domain_object!(domain_object, dto)
        domain_object
      end

      def build_domain_object!(domain_object, dto)
      end

      def build_dto(domain_object)
        return nil if domain_object.nil?
        #FIXME: this method shouldn't really change id. Move it upwards.
        #FIXME: should it always change id of domain object?
        unless domain_object.id
          domain_object.id = id_generator.next_id
        end
        dto = {}
        dto['_id'] = domain_object.id
        build_dto!(dto, domain_object)
        dto
      end

      def build_dto!(dto, domain_object)
      end

      #TEST_ME
      def update_dto(dto, domain_object)
        return nil unless domain_object
        update_dto!(dto, domain_object)
        dto
      end

      #TEST_ME
      def update_dto!(dto, domain_object)
        build_dto!(dto, domain_object)
      end

      def link_domain_object(domain_object, dto)
        domain_object.id = dto['_id']
      end

      def id_generator
        @id_generator ||= BSONIdGenerator.new
      end

      attr_writer :id_generator

      def build_dtos(domain_objects)
        domain_objects.map do |domain_object|
          build_dto(domain_object)
        end
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
        dtos.map do |dto|
          build_domain_object(dto)
        end
      end

      private

        def update_dtos_collection(dtos, domain_objects)
          mapped_collection = build_mapped_collection
          mapped_collection.load_dtos(dtos)
          mapped_collection.update(domain_objects)
          mapped_collection.dict
        end

        def build_mapped_collection
          Mapping::MappedCollection.new(self)
        end
    end
  end
end

