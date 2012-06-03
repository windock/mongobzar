module Mongobzar
  module Mapping
    module HasCreatedAt
      def initialize(database_name)
        super
        @clock = Time
      end

      attr_accessor :clock

      def build_dto(domain_object)
        dto = super
        dto['created_at'] = @clock.now
        dto
      end

      def build_domain_object(dto)
        domain_object = super
        domain_object.created_at = dto['created_at']
        domain_object
      end

      def update_domain_object_after_insert(domain_object, dto)
        super
        domain_object.created_at = dto['created_at']
      end
    end
  end
end