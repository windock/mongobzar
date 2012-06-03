require_relative 'spec_helper'
require_relative '../../lib/mongobzar/mapping/mapper'
require_relative '../../lib/mongobzar/mapping/mapped_collection'
require_relative '../../lib/mongobzar/mapping/embedded_mapper'

module Mongobzar
  module Test
    class Person
      attr_accessor :id
      attr_reader :addresses
      attr_accessor :work_address

      def initialize
        @addresses = []
      end

      def add_address(address)
        @addresses << address
      end

      def remove_address(address)
        @addresses.delete(address)
      end
    end

    class Address
      attr_accessor :id, :street

      def initialize(street)
        @street = street
      end
    end

    class PersonMapper < Mongobzar::Mapping::Mapper
      def initialize(database_name)
        super
        set_mongo_collection('people')
        @address_mapper = AddressMapper.new
      end

      def build_new(dto={})
        Person.new
      end

      def build_domain_object!(person, dto)
        @address_mapper.domain_objects(dto['addresses']).each do |address|
          person.add_address(address)
        end
        person.work_address = @address_mapper.build_domain_object(dto['work_address'])
      end

      def build_dto!(dto, person)
        dto['addresses'] = @address_mapper.build_embedded_collection(person.addresses)
        dto['work_address'] = @address_mapper.build_embedded_dto(person.work_address)
      end

      def update_dto!(dto, person)
        dto['addresses'] = @address_mapper.update_embedded_collection(dto['addresses'], person.addresses)
        dto['work_address'] = @address_mapper.update_embedded_dto(dto['work_address'], person.work_address)
      end
    end

    class AddressMapper < Mongobzar::Mapping::EmbeddedMapper
      def build_dto!(dto, address)
        dto['street'] = address.street
      end

      def build_new(dto={})
        Address.new(dto['street'])
      end
    end

    class AddressMappingMatcher < MappingMatcher
      def assert_single_loaded(specification, address)
        refute_nil address
        refute_nil address.id
        assert_equal specification.id, address.id
        assert_equal specification.street, address.street
      end

      def assert_single_persisted(address, dto)
        refute_nil dto
        refute_nil dto['_id']
        assert_equal address.id, dto['_id']
        assert_equal address.street, dto['street']
      end

      def assert_embedded_persisted(domain_objects, mongo_collection)
        assert_equal domain_objects.size, mongo_collection.size
        domain_objects.each_with_index do |domain_object, i|
          assert_single_persisted(domain_object, mongo_collection[i])
        end
      end
    end
  end
end

include Mongobzar::Test
describe 'Embedded association with identity' do
  def people_documents
    @people_collection.find.to_a
  end

  before do
    @connection = Mongo::Connection.new
    @db = @connection.db('testing')
    @people_collection = @db.collection('people')
    @person_mapper = PersonMapper.new('testing')
    @person_mapper.clear_everything!

    @person = Person.new
    @matcher = AddressMappingMatcher.new
  end

  describe 'one' do
    before do
      @work_address = Address.new('Work street')
    end

    def find_work_address_document
      people_documents[0]['work_address']
    end

    describe 'insert' do
      it 'puts embedded document to the parent document' do
        @person.work_address = @work_address
        @person_mapper.insert(@person)
        @matcher.assert_single_persisted(@work_address, find_work_address_document)
      end
    end

    describe 'update' do
      it 'updates embedded document preserving id' do
        @person.work_address = @work_address
        @person_mapper.insert(@person)
        work_address_original_id = @work_address.id

        @work_address.street = 'New street'
        @person_mapper.update(@person)
        work_address_document = find_work_address_document
        @matcher.assert_single_persisted(@work_address, work_address_document)
        assert_equal work_address_original_id, work_address_document['_id']
      end
    end

    describe 'find' do
      it 'returns domain object with related domain object' do
        @person.work_address = @work_address
        @person_mapper.insert(@person)
        @matcher.assert_single_loaded(@work_address, @person_mapper.find(@person.id).work_address)
      end
    end
  end

  describe 'many' do
    before do
      @address1 = Address.new('street1')
      @address2 = Address.new('street2')
      @address3 = Address.new('street3')
      @address4 = Address.new('street4')
    end

    def find_address_documents
      people_documents[0]['addresses']
    end

    describe 'insert' do
      it 'puts embedded documents to the parent document' do
        @person.add_address(@address1)
        @person.add_address(@address2)
        @person_mapper.insert(@person)
        @matcher.assert_embedded_persisted([@address1, @address2], find_address_documents)
      end
    end

    describe 'update' do
      describe 'updates embedded documents' do
        describe 'creates new' do
          it 'works if was empty' do
            @person_mapper.insert(@person)
            @person.add_address(@address1)
            @person.add_address(@address2)
            @person_mapper.update(@person)
            @matcher.assert_embedded_persisted([@address1, @address2], find_address_documents)
          end

          it 'works if was not empty, preserving ids' do
            @person.add_address(@address1)
            @person_mapper.insert(@person)
            address1_original_id = @address1.id

            @person.add_address(@address2)
            @person_mapper.update(@person)

            address_documents = find_address_documents
            @matcher.assert_embedded_persisted([@address1, @address2], address_documents)
            assert_equal address1_original_id, address_documents[0]['_id']
          end
        end

        it 'deletes removed' do
          [@address1, @address2, @address3, @address4].each do |address|
            @person.add_address(address)
          end
          @person_mapper.insert(@person)
          @person.remove_address(@address1)
          @person.remove_address(@address3)
          @person_mapper.update(@person)

          @matcher.assert_embedded_persisted([@address2, @address4], find_address_documents)
        end

        it 'updates existing, preserving ids' do
          @person.add_address(@address1)
          @person_mapper.insert(@person)
          original_id = @address1.id

          @address1.street = 'new_street'
          @person_mapper.update(@person)

          address_documents = find_address_documents
          @matcher.assert_embedded_persisted([@address1], address_documents)
          assert_equal original_id, address_documents[0]['_id']
        end
      end
    end

    describe 'find' do
      it 'returns domain object with related domain objects' do
        @person.add_address(@address1)
        @person.add_address(@address2)
        @person_mapper.insert(@person)

        @matcher.assert_loaded([@address1, @address2], @person_mapper.find(@person.id).addresses)
      end
    end
  end
end
