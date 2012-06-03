module Mongobzar
  module Test
    class MappingMatcher
      include RSpec::Matchers::DSL
      include RSpec::Matchers

      def assert_dependent_persisted(domain_objects, parent, collection)
        domain_objects.size.should == collection.size
        domain_objects.each_with_index do |domain_object, i|
          assert_single_dependent_persisted(domain_object, parent, collection[i])
        end
      end

      def assert_persisted(domain_objects, mongo_collection)
        domain_objects.size.should == mongo_collection.size
        domain_objects.each_with_index do |domain_object, i|
          assert_single_persisted(domain_object, mongo_collection[i])
        end
      end

      def assert_loaded(specifications, domain_objects)
        specifications.size.should == domain_objects.size
        specifications.each_with_index do |specification, i|
          assert_single_loaded(specification, domain_objects[i])
        end
      end
    end
  end
end
