require 'mongobzar/assembler/polymorphic_assembler'

module Mongobzar
  module Assembler
    describe PolymorphicAssembler do
      class DomainObject1
      end

      class DomainObject2
      end

      let(:domain_object1) { DomainObject1.new }
      let(:domain_object2) { DomainObject2.new }

      let(:assembler1) { stub }
      let(:assembler2) { stub }
      subject { PolymorphicAssembler.new([assembler1, assembler2]) }

      context 'building dtos' do
        let(:assembler1) do
          res = stub(domain_object_class: DomainObject1)
          res.stub!(:build_dto).with(domain_object1) { dto1 }
          res
        end

        let(:assembler2) do
          res = stub(domain_object_class: DomainObject2)
          res.stub!(:build_dto).with(domain_object2) { dto2 }
          res
        end

        let(:dto1) { stub('Dto1') }
        let(:dto2) { stub('Dto2') }

        context '#build_dto' do
          it 'delegates to the appropriate assembler' do
            subject.build_dto(domain_object1).should == dto1
            subject.build_dto(domain_object2).should == dto2
          end
        end

        context '#update_dto' do
          it 'delegates to the appropriate assembler' do
            assembler1.should_receive(:update_dto).with(dto1, domain_object1)
            subject.update_dto(dto1, domain_object1)

            assembler2.should_receive(:update_dto).with(dto2, domain_object2)
            subject.update_dto(dto2, domain_object2)
          end
        end

        context '#build_dtos' do
          it 'delegates building of each dto to an appropriate assembler' do
            subject.build_dtos([domain_object1, domain_object2]).should ==
              [dto1, dto2]
            subject.build_dtos([domain_object1, domain_object1]).should ==
              [dto1, dto1]
          end
        end
      end

      context '#link_domain_object' do
        it 'delegates to an appropriate assembler' do
          dto1, dto2 = stub, stub
          assembler1.stub!(:domain_object_class) { DomainObject1 }
          assembler2.stub!(:domain_object_class) { DomainObject2 }

          assembler1.should_receive(:link_domain_object).
            with(domain_object1, dto1)
          assembler2.should_receive(:link_domain_object).
            with(domain_object2, dto2)

          subject.link_domain_object(domain_object1, dto1)
          subject.link_domain_object(domain_object2, dto2)
        end
      end

      context 'building domain objects' do
        let(:dto1)  { { 'type' => 't1' } }
        let(:dto2)  { { 'type' => 't2' } }
        let(:domain_object1) { stub }
        let(:domain_object2) { stub }

        before do
          assembler1.stub!(:type_code) { 't1' }
          assembler2.stub!(:type_code) { 't2' }

          assembler1.stub!(:build_domain_object).with(dto1) {
            domain_object1
          }

          assembler2.stub!(:build_domain_object).with(dto2) {
            domain_object2
          }
        end

        context '#build_domain_object' do
          it 'delegates to an appropriate assembler' do
            subject.build_domain_object(dto1).should == domain_object1
            subject.build_domain_object(dto2).should == domain_object2
          end
        end

        context '#build_domain_objects' do
          it 'delegates building of each domain object to an
              appropriate assembler' do
            subject.build_domain_objects(
              [dto1, dto2]).should == [domain_object1, domain_object2]
            subject.build_domain_objects(
              [dto1, dto1]).should == [domain_object1, domain_object1]
          end
        end
      end
    end
  end
end
