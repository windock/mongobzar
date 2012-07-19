module Mongobzar
  module Test
    class MappingMatcher
      include RSpec::Matchers::DSL
      include RSpec::Matchers

      def assert_correct_dependent_dtos(objs, parent, dtos)
        objs.size.should == dtos.size
        objs.each_with_index do |obj, i|
          assert_correct_dependent_dto(obj, parent, dtos[i])
        end
      end

      def assert_correct_dtos_collection(objs, dtos)
        objs.size.should == dtos.size
        objs.each_with_index do |obj, i|
          assert_correct_dto(obj, dtos[i])
        end
      end

      def assert_loaded(specifications, objs)
        specifications.size.should == objs.size
        specifications.each_with_index do |specification, i|
          assert_single_loaded(specification, objs[i])
        end
      end
    end

    class EmbeddedMappingMatcher < MappingMatcher
      def initialize(collection)
        @collection = collection
      end

      attr_reader :collection

      def assert_single_persisted(address)
        assert_correct_dto(address, find_one_document)
      end

      def assert_persisted(addresses)
        dtos = find_many_documents
        assert_correct_dtos_collection(addresses, dtos)
      end

      def assert_the_same_id(address, given_id)
        dtos = find_many_documents
        given_id.should == dtos[0]['_id']
      end

      def assert_single_persisted_with_given_id(obj, given_id)
        dto = find_one_document
        assert_correct_dto(obj, dto)
        given_id.should == dto['_id']
      end
    end

  end
end
