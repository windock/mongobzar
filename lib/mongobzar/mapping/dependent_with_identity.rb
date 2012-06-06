module Mongobzar
  module Mapping
    module DependentWithIdentity
      def build_domain_objects(dtos)
        mapped_collection = build_mapped_collection
        mapped_collection.load_dtos(dtos)
        mapped_collection.domain_objects
      end

      protected
        def build_dtos_collection(domain_objects)
          mapped_collection = build_mapped_collection
          mapped_collection.load_domain_objects(domain_objects)
          dict = mapped_collection.dict
          dtos = dict.values
          [dict, dtos]
        end

        def update_dtos_collection(dtos, domain_objects)
          mapped_collection = build_mapped_collection
          mapped_collection.load_dtos(dtos)
          mapped_collection.update(domain_objects)
          mapped_collection.dict
        end

      private
        def build_mapped_collection
          MappedCollection.new(self)
        end
    end
  end
end
