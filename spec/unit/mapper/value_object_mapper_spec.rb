require 'mongobzar/mapper/value_object_mapper'

module Mongobzar
  module Mapper
    module Test
      class Sample
        def initialize(string=nil, number=nil)
          @string, @number = string, number
        end

        def ==(o)
          string == o.string &&
          number == o.number
        end

        attr_accessor :string, :number
      end

      class SampleMapper
        def build_new(dto)
          Sample.new
        end

        def build_domain_object!(domain_object, dto)
          domain_object.number = dto['number']
          domain_object.string = dto['string']
        end

        def build_dto!(dto, domain_object)
          dto['number'] = domain_object.number
          dto['string'] = domain_object.string
        end

        def update_dto!(dto, domain_object)
          dto['string'] = 'updated_string'
          dto['number'] = domain_object.number
        end
      end

      describe ValueObjectMapper do
        subject { ValueObjectMapper.new(SampleMapper.new) }
        let(:sample_string) { 'sample_string' }
        let(:sample_number) { 5 }
        let(:sample_dto) do
          {
            'number' => sample_number,
            'string' => sample_string
          }
        end
        let(:sample_obj) { Sample.new(sample_string, sample_number) }

        context 'working with collections' do
          let(:obj1) { Sample.new('s1', 1) }
          let(:obj2) { Sample.new('s2', 2) }
          let(:dto1) { { 'string' => 's1', 'number' => 1 } }
          let(:dto2) { { 'string' => 's2', 'number' => 2 } }

          context '#build_domain_objects' do
            it 'is empty array if domain objects is empty array' do
              subject.build_domain_objects([]).should == []
            end

            it 'builds domain object for every dto' do
              subject.build_domain_objects([dto1, dto2]).should == [obj1, obj2]
            end
          end

          context '#build_dtos' do
            it 'is empty array if dtos is empty array' do
              subject.build_dtos([]).should == []
            end

            it 'builds dtos for every domain object' do
              subject.build_dtos([obj1, obj2]).should == [dto1, dto2]
            end
          end
        end

        context '#build_domain_object' do
          it 'returns nil if dto is nil' do
            subject.build_domain_object(nil).should == nil
          end

          it 'builds domain object using build_new and build_domain_object!' do
            subject.build_domain_object(sample_dto).should == sample_obj
          end
        end

        context '#build_dto' do
          it 'returns nil if domain object is nil' do
            subject.build_dto(nil).should == nil
          end

          it 'creates a hash and populates it with build_dto!' do
            subject.build_dto(sample_obj).should == sample_dto
          end
        end

        context '#update_dto' do
          it 'returns nil if domain object is nil' do
            subject.update_dto(stub, nil).should == nil
          end

          it 'updates dto using update_dto!' do
            subject.update_dto(sample_dto, Sample.new('new_string', 42)).should == { 'string' => 'updated_string', 'number' => 42 }
          end
        end
      end
    end
  end
end
