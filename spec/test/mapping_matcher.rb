module Mongobzar
  module Test
    class MappingMatcher
      include MiniTest::Assertions
      def assert_dependent_persisted(domain_objects, parent, collection)
        assert_equal domain_objects.size, collection.size
        domain_objects.each_with_index do |domain_object, i|
          assert_single_dependent_persisted(domain_object, parent, collection[i])
        end
      end

      def assert_persisted(domain_objects, mongo_collection)
        assert_equal domain_objects.size, mongo_collection.size
        domain_objects.each_with_index do |domain_object, i|
          assert_single_persisted(domain_object, mongo_collection[i])
        end
      end

      def assert_loaded(specifications, domain_objects)
        assert_equal specifications.size, domain_objects.size
        specifications.each_with_index do |specification, i|
          assert_single_loaded(specification, domain_objects[i])
        end
      end
    end
  end
end