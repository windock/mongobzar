require 'mongobzar/mapper/polymorphic_mapper'
require 'mongobzar/mapper/inheritance_mapper'
require 'mongobzar/mapper/entity_mapper'
require 'mongobzar/mapper/value_object_mapper'

module Mongobzar
  module Mapper
    module Test
      class Sub1
        def foo
          'foo1'
        end
      end

      class Sub2
        attr_accessor :id

        def foo
          'foo2'
        end
      end

      class Sub1Mapper < Mapper
        def build_new(dto={})
          Sub1.new
        end
      end

      class Sub2Mapper < Mapper
        def build_new(dto={})
          Sub2.new
        end
      end

      describe PolymorphicMapper do
        let(:sub1_mapper) do
          InheritanceMapper.new(Sub1, 'sub1', ValueObjectMapper.new(Sub1Mapper.new))
        end

        let(:sub2_mapper) do
          entity_mapper = EntityMapper.new(Sub2Mapper.new)
          InheritanceMapper.new(Sub2, 'sub2', entity_mapper)
        end

        subject do
          PolymorphicMapper.new([
            sub1_mapper,
            sub2_mapper
          ])
        end

        context 'given dto with type sub1' do
          let(:dto) do
            { 'type' => 'sub1' }
          end

          it 'builds domain object of class Sub1 from it' do
            subject.build_domain_object(dto).foo.should == 'foo1'
          end
        end

        context 'given dto with type sub2' do
          let(:sample_id) { stub }
          let(:dto) do
            { 'type' => 'sub2', '_id' => sample_id }
          end

          it 'builds domain object of class Sub2 and sets id' do
            obj = subject.build_domain_object(dto)
            obj.foo.should == 'foo2'
            obj.id.should == sample_id
          end
        end

        context 'given domain object of class Sub1' do
          let(:obj) { Sub1.new }

          it 'builds dto with sub1 from it' do
            subject.build_dto(obj)['type'].should == 'sub1'
          end
        end
      end
    end
  end
end
