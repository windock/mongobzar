require 'mongobzar/assembler/polymorphic_assembler'
require 'mongobzar/assembler/inheritance_assembler'
require 'mongobzar/assembler/entity_assembler'
require 'mongobzar/assembler/value_object_assembler'

module Mongobzar
  module Assembler
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

      class Sub1Assembler < Assembler
        def build_new(dto={})
          Sub1.new
        end
      end

      class Sub2Assembler < Assembler
        def build_new(dto={})
          Sub2.new
        end
      end

      describe PolymorphicAssembler do
        let(:sub1_assembler) do
          InheritanceAssembler.new(Sub1, 'sub1', ValueObjectAssembler.new(Sub1Assembler.new))
        end

        let(:sub2_assembler) do
          entity_assembler = EntityAssembler.new(Sub2Assembler.new)
          InheritanceAssembler.new(Sub2, 'sub2', entity_assembler)
        end

        subject do
          PolymorphicAssembler.new([
            sub1_assembler,
            sub2_assembler
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
