require 'mongobzar/assembler/inheritance_assembler'

module Mongobzar
  module Assembler
    module Test
      class Sub1
        attr_accessor :id

        def ==(o)
          o.class == self.class &&
          o.id == self.id
        end
      end

      describe InheritanceAssembler do
        let(:assembler) { stub(build_domain_object!: nil, build_new: Sub1.new) }
        subject do
          InheritanceAssembler.new(Sub1, 'sub1', assembler)
        end

        describe '#build_dto!' do
          it 'sets type to dto' do
            assembler.stub!(:build_dto!)
            dto = {}
            subject.build_dto!(dto, stub)
            dto.should == { 'type' => 'sub1' }
          end
        end

        it 'stores domain_object_class' do
          subject.domain_object_class.should == Sub1
        end

        it 'stores type_code' do
          subject.type_code.should == 'sub1'
        end

        it 'may have assembler injected' do
          assembler = stub
          subject.assembler = stub
          subject.assembler = assembler
        end
      end
    end
  end
end
