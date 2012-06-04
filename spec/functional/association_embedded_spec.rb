require_relative 'spec_helper'
require_relative '../test/person'
require_relative '../../lib/mongobzar/mapping/mapper'
require_relative '../../lib/mongobzar/mapping/embedded_mapper'

module Mongobzar
  module Test
    class Address
      attr_accessor :street

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

      def build_dto!(dto, person)
        dto['work_address'] = @address_mapper.build_embedded_dto(person.work_address)
      end

      def build_new(dto={})
        Person.new
      end

      def build_domain_object!(person, dto)
        person.work_address = @address_mapper.build_domain_object(dto['work_address'])
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
        address.should_not be_nil
        specification.street.should == address.street
      end

      def assert_single_persisted(address, dto)
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
    @person_mapper = PersonMapper.new('testing')
    @person_mapper.clear_everything!

    @person = Person.new
    @matcher = AddressMappingMatcher.new
  end

  def people_documents
    @people_collection.find.to_a
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
      it 'updates embedded document' do
        @person.work_address = @work_address
        @person_mapper.insert(@person)
        @work_address.street = 'New street'
        @person_mapper.update(@person)
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
      @address1 = AddressWithId.new('street1')
      @address2 = AddressWithId.new('street2')
      @address3 = AddressWithId.new('street3')
      @address4 = AddressWithId.new('street4')
    end

    describe 'insert' do
      it 'puts embedded documents to the parent document' do
        pending
        @person.add_address(@address1)
        @person.add_address(@address2)
        @person_mapper.insert(@person)
        @matcher.assert_embedded_persisted([@address1, @address2],
                                           find_address_documents)
      end
    end
  end
end
