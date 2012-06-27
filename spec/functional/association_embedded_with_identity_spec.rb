require_relative 'spec_helper'
require_relative '../../lib/mongobzar/mapping/mapper'
require_relative '../../lib/mongobzar/mapping/mapped_collection'
require_relative '../../lib/mongobzar/mapping/embedded_with_identity_mapper'
require_relative '../test/person'

module Mongobzar
  module Test
    class AddressWithId
      attr_accessor :id, :street

      def initialize(street)
        @street = street
      end
    end

    class PersonHavingAddressesWithIdMappingStrategy < Mapping::MappingStrategy
      def initialize(address_mapper)
        @address_mapper = address_mapper
      end

      def build_new(dto)
        Person.new
      end

      def build_domain_object!(person, dto)
        @address_mapper.build_domain_objects(dto['addresses']).each do |address|
          person.add_address(address)
        end
        person.work_address = @address_mapper.build_domain_object(
          dto['work_address']
        )
      end

      def build_dto!(dto, person)
        dto['addresses'] = @address_mapper.build_dtos(
          person.addresses
        )
        dto['work_address'] = @address_mapper.build_dto(
          person.work_address
        )
      end

      def update_dto!(dto, person)
        dto['addresses'] = @address_mapper.update_dtos(
          dto['addresses'], person.addresses
        )
        dto['work_address'] = @address_mapper.update_dto(
          dto['work_address'], person.work_address
        )
      end
    end

    class PersonHavingAddressesWithIdMapper < Mongobzar::Mapping::Mapper
      def initialize(database_name)
        super
        @address_mapper = AddressWithIdMapper.new
      end

      def mongo_collection_name
        'people_having_addresses_with_id'
      end

      def mapping_strategy
        PersonHavingAddressesWithIdMappingStrategy.new(@address_mapper)
      end
    end

    class AddressWithIdMapper < Mongobzar::Mapping::EmbeddedWithIdentityMapper
      def mapping_strategy
        Class.new(Mapping::WithIdentityMappingStrategy) do
          def build_new(dto)
            AddressWithId.new(dto['street'])
          end

          def build_dto!(dto, address)
            dto['street'] = address.street
          end
        end.new
      end
    end

    class AddressWithIdentityMappingMatcher < EmbeddedMappingMatcher
      def find_one_document
        collection.find.to_a[0]['work_address']
      end

      def find_many_documents
        collection.find.to_a[0]['addresses']
      end

      def assert_single_loaded(specification, address)
        address.should_not be_nil
        address.id.should_not be_nil
        specification.id.should == address.id
        specification.street.should == address.street
      end

      def assert_correct_dto(address, dto)
        dto.should_not be_nil
        dto['_id'].should_not be_nil
        address.id.should == dto['_id']
        address.street.should == dto['street']
      end

      def assert_correct_dtos_collection(addresses, dtos)
        addresses.size.should == dtos.size
        addresses.each_with_index do |address, i|
          assert_correct_dto(address, dtos[i])
        end
      end
    end
  end
end

include Mongobzar::Test
describe 'Embedded association with identity' do
  before do
    setup_connection
    @people_collection = @db.collection('people_having_addresses_with_id')
    @person_mapper = PersonHavingAddressesWithIdMapper.new('testing')
    @person_mapper.clear_everything!

    @person = Person.new
    @matcher = AddressWithIdentityMappingMatcher.new(@people_collection)
  end

  describe 'one' do
    before do
      @work_address = AddressWithId.new('Work street')
    end

    describe 'insert' do
      it 'puts embedded document to the parent document' do
        @person.work_address = @work_address
        @person_mapper.insert(@person)
        @matcher.assert_single_persisted(@work_address)
      end
    end

    describe 'update' do
      it 'updates embedded document preserving id' do
        @person.work_address = @work_address
        @person_mapper.insert(@person)
        work_address_original_id = @work_address.id

        @work_address.street = 'New street'
        @person_mapper.update(@person)
        @matcher.assert_single_persisted_with_given_id(@work_address, work_address_original_id)
      end
    end

    describe 'find' do
      it 'returns domain object with related domain object' do
        @person.work_address = @work_address
        @person_mapper.insert(@person)
        @matcher.assert_single_loaded(
          @work_address,
          @person_mapper.find(@person.id).work_address
        )
      end
    end
  end

  describe 'many' do
    before do
      @address = AddressWithId.new('street')
      @address2 = AddressWithId.new('street2')
      @address3 = AddressWithId.new('street3')
      @address4 = AddressWithId.new('street4')
    end

    describe 'insert' do
      it 'puts embedded documents to the parent document' do
        @person.add_address(@address)
        @person.add_address(@address2)
        @person_mapper.insert(@person)
        @matcher.assert_persisted([@address, @address2])
      end
    end

    describe 'update' do
      describe 'updates embedded documents' do
        describe 'creates new' do
          it 'works if was empty' do
            @person_mapper.insert(@person)
            @person.add_address(@address)
            @person.add_address(@address2)
            @person_mapper.update(@person)
            @matcher.assert_persisted([@address, @address2])
          end

          it 'works if was not empty, preserving ids' do
            @person.add_address(@address)
            @person_mapper.insert(@person)
            address_original_id = @address.id

            @person.add_address(@address2)
            @person_mapper.update(@person)

            @matcher.assert_persisted([@address, @address2])
            @matcher.assert_the_same_id(@address, address_original_id)
          end
        end

        it 'deletes removed' do
          [@address, @address2, @address3, @address4].each do |address|
            @person.add_address(address)
          end
          @person_mapper.insert(@person)
          @person.remove_address(@address)
          @person.remove_address(@address3)
          @person_mapper.update(@person)

          @matcher.assert_persisted([@address2, @address4])
        end

        it 'updates existing, preserving ids' do
          @person.add_address(@address)
          @person_mapper.insert(@person)
          original_id = @address.id

          @address.street = 'new_street'
          @person_mapper.update(@person)

          @matcher.assert_persisted([@address])
          @matcher.assert_the_same_id(@address, original_id)
        end
      end
    end

    describe 'find' do
      it 'returns domain object with related domain objects' do
        @person.add_address(@address)
        @person.add_address(@address2)
        @person_mapper.insert(@person)

        @matcher.assert_loaded([@address, @address2], @person_mapper.find(@person.id).addresses)
      end
    end
  end
end
