require_relative 'spec_helper'
require_relative '../test/person'
require 'mongobzar/repository/repository'
require 'mongobzar/mapping_strategy/value_object_mapping_strategy'
require 'mongobzar/mapping_strategy/simple_mapping_strategy'

module Mongobzar
  module Test
    class Address
      attr_accessor :street

      def initialize(street)
        @street = street
      end
    end

    class PersonMappingStrategy < MappingStrategy::EntityMappingStrategy
      def initialize(address_mapping_strategy)
        @address_mapping_strategy = address_mapping_strategy
      end

      def build_dto!(dto, person)
        dto['work_address'] = address_mapping_strategy.build_dto(person.work_address)
        dto['addresses'] = address_mapping_strategy.build_dtos(person.addresses)
      end

      def build_new(dto={})
        Person.new
      end

      def build_domain_object!(person, dto)
        address_mapping_strategy.build_domain_objects(dto['addresses']).each do |address|
          person.add_address(address)
        end
        person.work_address = address_mapping_strategy.build_domain_object(dto['work_address'])
      end

      private
        attr_reader :address_mapping_strategy
    end

    class PersonRepository < Mongobzar::Repository::Repository
      def mongo_collection_name
        'people'
      end

      def mapping_strategy
        PersonMappingStrategy.new(address_mapping_strategy)
      end

      def address_mapping_strategy
        MappingStrategy::SimpleMappingStrategy.new(->(dto) { Address.new(dto['street']) }, [:street])
      end
    end

    class AddressMappingMatcher < EmbeddedMappingMatcher
      def assert_single_loaded(specification, address)
        address.should_not be_nil
        specification.street.should == address.street
      end

      def find_one_document
        collection.find.to_a[0]['work_address']
      end

      def find_many_documents
        collection.find.to_a[0]['addresses']
      end

      def assert_correct_dto(address, dto)
        dto.should_not be_nil
        address.street.should == dto['street']
      end
    end
  end
end

include Mongobzar::Test
describe 'Embedded association' do
  before do
    setup_connection
    @people_collection = @db.collection('people')
    @person_repository = PersonRepository.new('testing')
    @person_repository.clear_everything!

    @person = Person.new
    @matcher = AddressMappingMatcher.new(@people_collection)
  end

  def people_documents
    @people_collection.find.to_a
  end

  describe 'one' do
    before do
      @work_address = Address.new('Work street')
    end

    describe 'insert' do
      it 'puts embedded document to the parent document' do
        @person.work_address = @work_address
        @person_repository.insert(@person)
        @matcher.assert_single_persisted(@work_address)
      end
    end

    describe 'update' do
      it 'updates embedded document' do
        @person.work_address = @work_address
        @person_repository.insert(@person)
        @work_address.street = 'New street'
        @person_repository.update(@person)
        @matcher.assert_single_persisted(@work_address)
      end
    end

    describe 'find' do
      it 'returns domain object with related domain object' do
        @person.work_address = @work_address
        @person_repository.insert(@person)
        @matcher.assert_single_loaded(@work_address, @person_repository.find(@person.id).work_address)
      end
    end
  end

  describe 'many' do
    before do
      @address = Address.new('street')
      @address2 = Address.new('street2')
      @address3 = Address.new('street3')
      @address4 = Address.new('street4')
    end

    describe 'insert' do
      it 'puts embedded documents to the parent document' do
        @person.add_address(@address)
        @person.add_address(@address2)
        @person_repository.insert(@person)
        @matcher.assert_persisted([@address, @address2])
      end
    end

    describe 'update' do
      describe 'update embedded documents' do
        describe 'creates new' do
          it 'works if was empty' do
            @person_repository.insert(@person)
            @person.add_address(@address)
            @person.add_address(@address2)
            @person_repository.update(@person)
            @matcher.assert_persisted([@address, @address2])
          end

          it 'works is was not empty' do
            @person.add_address(@address)
            @person_repository.insert(@person)

            @person.add_address(@address2)
            @person_repository.update(@person)

            @matcher.assert_persisted([@address, @address2])
          end
        end

        it 'deletes removed' do
          [@address, @address2, @address3, @address4].each do |address|
            @person.add_address(address)
          end
          @person_repository.insert(@person)
          @person.remove_address(@address)
          @person.remove_address(@address3)
          @person_repository.update(@person)

          @matcher.assert_persisted([@address2, @address4])
        end

        it 'updates existing' do
          @person.add_address(@address)
          @person_repository.insert(@person)

          @address.street = 'new_street'
          @person_repository.update(@person)

          @matcher.assert_persisted([@address])
        end
      end
    end

    describe 'find' do
      it 'returns domain object with related domain objects' do
        @person.add_address(@address)
        @person.add_address(@address2)
        @person_repository.insert(@person)

        @matcher.assert_loaded([@address, @address2], @person_repository.find(@person.id).addresses)
      end
    end
  end
end
