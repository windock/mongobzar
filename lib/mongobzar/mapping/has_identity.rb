module Mongobzar
  module Mapping
    module HasIdentity
      def build_dto(domain_object)
        dto = super
        add_identity_to_dto!(dto)
        dto
      end

      def add_identity_to_dto!(dto)
        dto['_id'] = BSON::ObjectId.new
      end

      #TODO: add build_domain_object!(domain_object, dto)
      #for cases, where not everything may be done in constructor
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
