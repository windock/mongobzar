require_relative 'base_mapper_with_identity'

module Mongobzar
  module Mapping
    class EmbeddedWithIdentityMapper < BaseMapperWithIdentity
      def build_embedded_dto(domain_object)
        return nil unless domain_object
        dto = build_dto(domain_object)
        domain_object.id = dto['_id']
        dto
      end

      def update_embedded_dto(dto, domain_object)
        return nil unless domain_object
        update_dto!(dto, domain_object)
        dto
      end

      def build_embedded_collection(domain_objects)
        mapped_collection = build_mapped_collection
        mapped_collection.load_domain_objects(domain_objects)
        dict = mapped_collection.dict
        dict.each do |domain_object, dto|
          link_domain_object(domain_object, dto)
        end
        dict.values
      end

      def update_embedded_collection(dtos, domain_objects)
        mapped_collection = build_mapped_collection
        mapped_collection.load_dtos(dtos)
        mapped_collection.update(domain_objects)
        dict = mapped_collection.dict
        dict.each do |domain_object, dto|
          link_domain_object(domain_object, dto)
        end
        dict.values
      end

      def link_domain_object(domain_object, dto)
        domain_object.id = dto['_id']
      end

      def build_domain_objects(dtos)
        mapped_collection = build_mapped_collection
        mapped_collection.load_dtos(dtos)
        mapped_collection.domain_objects
      end

      #TODO: add build_domain_object!(domain_object, dto)
      #for cases, where not everything may be done in constructor
      def build_domain_object(dto)
        return nil unless dto
        domain_object = build_new(dto)
        domain_object.id = dto['_id']
        domain_object
      end

      private
        def build_mapped_collection
          Mongobzar::Mapping::MappedCollection.new(self)
        end
    end
  end
end
