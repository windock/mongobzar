require 'mongobzar/mapping_strategy/entity_mapping_strategy'
require 'mongobzar/bson_id_generator'

module Mongobzar
  module MappingStrategy
    module Test
      class SampleWithId
        def initialize(string=nil, id=nil)
          @string = string
          @id = id
        end

        def ==(o)
          string == o.string &&
          id == o.id
        end

        attr_accessor :string, :id
      end

      class SampleEntityMappingStrategy < EntityMappingStrategy
        def build_new(dto)
          SampleWithId.new
        end

        def build_domain_object!(domain_object, dto)
          domain_object.string = dto['string']
        end

        def build_dto!(dto, domain_object)
          dto['string'] = domain_object.string
        end

        def update_dto!(dto, domain_object)
          dto['string'] = 'updated_string'
        end
      end

      describe EntityMappingStrategy do
        subject { SampleEntityMappingStrategy.new }

        let(:sample_id) { 'sample_id' }
        let(:sample_string) { 'sample_string' }
        let(:obj) { res = SampleWithId.new(sample_string) }

        context '#link_domain_object' do
          context 'given domain object with writable id and dto with _id' do
            it 'sets domain object\'s id with dto\'s _id' do
              domain_object = SampleWithId.new
              subject.link_domain_object(domain_object, { '_id' => sample_id })
              domain_object.id.should == sample_id
            end
          end
        end

        context '#id_generator' do
          it 'has default value of BSONIdGenerator' do
            subject.id_generator.should be_kind_of(BSONIdGenerator)
          end
        end

        context '#build_dto' do
          it 'returns nil if domain object is nil' do
            subject.build_dto(nil).should == nil
          end

          context 'if given domain object doesn\'t have an id' do
            before do
              subject.id_generator = stub(next_id: sample_id)
            end

            it 'generates new id for domain object if it is not present' do
              subject.build_dto(obj)
              obj.id.should == sample_id
            end

            it 'doesn\'t change id if it is present' do
              obj.id = 5
              subject.build_dto(obj)
              obj.id.should == 5
            end

            it 'builds dto from domain object using build_dto! and sets id' do
              subject.build_dto(obj).should == {
                '_id' => sample_id,
                'string' => sample_string
              }
            end
          end
        end

        context '#build_domain_object' do
          let(:dto_with_id) { { '_id' => sample_id, 'string' => sample_string } }

          let(:obj_with_id) do
            SampleWithId.new(sample_string, sample_id)
          end

          it 'returns nil if dto is nil' do
            subject.build_domain_object(nil).should == nil
          end

          context 'if dto is a hash that has _id' do
            it 'builds domain object using build_new and build_domain_object, and sets id' do
              obj = SampleWithId.new
              subject.build_domain_object(dto_with_id).should == obj_with_id
            end
          end
        end

        context '#link_domain_object' do
          it 'sets id of domain object to _id value of dto' do
            subject.link_domain_object(obj, { '_id' => sample_id })
            obj.id.should == sample_id
          end
        end

        context '#update_dto' do
          it 'returns nil if domain object is nil' do
            subject.update_dto(stub, nil).should == nil
          end

          it 'updates dto using update_dto!' do
            dto = { '_id' => sample_id, 'string' => sample_string }
            subject.update_dto(dto, SampleWithId.new('new_string')).should == { '_id' => sample_id, 'string' => 'updated_string' }
          end
        end
      end
    end
  end
end
