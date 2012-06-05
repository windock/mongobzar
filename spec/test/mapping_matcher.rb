module Mongobzar
  module Test
    class MappingMatcher
      include RSpec::Matchers::DSL
      include RSpec::Matchers

      def assert_correct_dependent_dtos(domain_objects, parent, dtos)
        domain_objects.size.should == dtos.size
        domain_objects.each_with_index do |domain_object, i|
          assert_correct_dependent_dto(domain_object, parent, dtos[i])
        end
      end

      def assert_correct_dtos_collection(domain_objects, dtos)
        domain_objects.size.should == dtos.size
        domain_objects.each_with_index do |domain_object, i|
          assert_correct_dto(domain_object, dtos[i])
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
