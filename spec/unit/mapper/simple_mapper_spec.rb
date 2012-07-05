require 'mongobzar/mapper/simple_mapper'

module Mongobzar
  module Mapper
    module Test
      describe SimpleMapper do
        class Sample
          def initialize(string=nil, number=nil)
            @string = string
            @number = number
          end

          def ==(o)
            string == o.string &&
            number == o.number
          end

          attr_accessor :string, :number
        end

        class SampleWithRequiredArguments < Sample
          def initialize(string)
            @string = string
          end
        end

        let(:sample_string) { 'sample_string' }
        let(:sample_number) { 5 }
        let(:obj) { Sample.new(sample_string, sample_number) }
        let(:sample_dto) { { string: sample_string, number: sample_number } }
        subject { SimpleMapper.new(->(dto) { Sample.new }) }

        context '#build_domain_object' do
          it 'returns nil if dto is nil' do
            subject.build_domain_object(nil).should == nil
          end

          context 'given no attributes' do
            it 'returns the result of build_new' do
              subject.build_domain_object(sample_dto).should == Sample.new
            end
          end

          context 'given attributes' do
            subject do
              SimpleMapper.new(->(dto) { Sample.new },
                                        [:string, :number])
            end

            it 'returns domain object with attributes set' do
              subject.build_domain_object(sample_dto).should == obj
            end

            context 'for dto with string keys' do
              it 'returns domain object with attributes set' do
                dto = {
                  'string' => sample_string,
                  'number' => sample_number
                }
                subject.build_domain_object(dto).should == obj
              end
            end
          end

          context 'for domain object with constructor that requires arguments' do
            it 'uses build_new with dto to build domain object' do
              strategy = SimpleMapper.new(
                ->(dto) { SampleWithRequiredArguments.new(dto['string']) },
                [:string, :number])
              strategy.build_domain_object(sample_dto).should == obj
            end
          end
        end

        context '#build_dto' do
          it 'returns nil if domain object is nil' do
            subject.build_dto(nil).should == nil
          end

          context 'given no attributes' do

            it 'builds dto as an empty hash' do
              subject.build_dto(obj).should == {}
            end
          end

          context 'given an array of attributes' do
            subject do
              SimpleMapper.new(->(dto) { Sample.new },
                                        [:string, :number])
            end

            it 'builds dto from domain object\'t attributes' do
              subject.build_dto(obj).should == sample_dto
            end
          end
        end
      end
    end
  end
end
