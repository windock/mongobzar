require 'mongobzar/mapping_strategy/with_identity_mapping_strategy'
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

      describe WithIdentityMappingStrategy do
        subject do
          WithIdentityMappingStrategy.new(mapping_strategy)
        end

        let(:mapping_strategy) { stub }
        let(:obj) do
          res = SampleWithId.new
          res.string = sample_string
          res
        end
        let(:sample_id) { 'sample_id' }
        let(:sample_string) { 'sample_string' }

        context 'undefined methods' do
          it 'delegates all undefined methods to mapping_strategy' do
            mapping_strategy.should_receive(:whatever).with('a', 1)
            subject.whatever('a', 1)
          end
        end

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
          context 'if domain object is nil' do
            it 'returns nil' do
              subject.build_dto(nil).should == nil
            end

            context 'if given domain object doesn\'t have an id' do
              before do
                subject.id_generator = stub(next_id: sample_id)
                dto = { 'string' => sample_string }
                mapping_strategy.stub!(:build_dto).with(obj) { dto }
              end

              it 'generates new id for domain object' do
                subject.build_dto(obj)
                obj.id.should == sample_id
              end

              it 'builds dto from domain object that has generated _id' do
                subject.build_dto(obj).should == {
                  '_id' => sample_id,
                  'string' => sample_string
                }
              end
            end
          end
        end

        context '#build_domain_object' do
          let(:dto_with_id) { { '_id' => sample_id, 'string' => sample_string } }

          let(:obj_with_id) do
            SampleWithId.new(sample_string, sample_id)
          end

          context 'if dto is nil' do
            it 'returns nil' do
              subject.build_domain_object(nil).should == nil
            end
          end

          context 'if dto is a hash that has _id' do
            it 'returns domain object with that _id' do
              obj = SampleWithId.new
              mapping_strategy.stub!(:build_new).with(dto_with_id) { obj }
              mapping_strategy.stub!(:build_domain_object!).with(obj, dto_with_id) do
                obj.string = sample_string
              end
              subject.build_domain_object(dto_with_id).should == obj_with_id
            end
          end

          context 'if dto doesn\'t have _id' do
            it 'TODO' do
            end
          end
        end
      end
    end
  end
end
