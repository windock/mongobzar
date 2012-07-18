require 'mongobzar/mapper/inheritance_mapper'

module Mongobzar
  module Mapper
    module Test
      class Sub1
        attr_accessor :id

        def ==(o)
          o.class == self.class &&
          o.id == self.id
        end
      end

      describe InheritanceMapper do
        let(:mapper) { stub(build_domain_object!: nil, build_new: Sub1.new) }
        subject do
          InheritanceMapper.new(Sub1, 'sub1', mapper)
        end

        describe '#build_dto!' do
          it 'sets type to dto' do
            mapper.stub!(:build_dto!)
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

        it 'may have mapper injected' do
          mapper = stub
          subject.mapper = stub
          subject.mapper = mapper
        end
      end
    end
  end
end
