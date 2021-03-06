require_relative 'spec_helper'
require_relative '../test/person'
require 'mongobzar/repository/repository'
require 'mongobzar/assembler/simple_assembler'
require 'mongobzar/assembler/entity_assembler'

module Mongobzar module Test
  class AddressWithId
    attr_accessor :id, :street

    def initialize(street)
      @street = street
    end
  end

  class PersonHavingAddressesWithIdAssembler < Assembler::Assembler
    def initialize(address_assembler)
      @address_assembler = address_assembler
    end

    def build_new(dto)
      Person.new
    end

    def build_domain_object!(person, dto)
      address_assembler.build_domain_objects(dto['addresses']).each do |address|
        person.add_address(address)
      end
      person.work_address = address_assembler.build_domain_object(
        dto['work_address']
      )
    end

    def build_dto!(dto, person)
      dto['addresses'] = person.addresses.map do |address|
        address_dto = address_assembler.build_dto(address)
        address.id = address_dto['_id']
        address_dto
      end
      if person.work_address
        dto['work_address'] = address_assembler.build_dto(person.work_address)
        person.work_address.id = dto['work_address']['_id']
      end
    end

    private
      attr_reader :address_assembler
  end

  class AddressWithIdAssembler < Assembler::Assembler
    def build_new(dto)
      AddressWithId.new(dto['street'])
    end

    def build_dto!(dto, address)
      dto['street'] = address.street
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
end end

module Mongobzar module Test
describe 'Embedded association with identity' do
  let(:people_collection) { @db.collection('people_having_addresses_with_id') }
  let(:person_repository) do
    res = Repository::Repository.new('testing', 'people_having_addresses_with_id')
    res.assembler = Assembler::EntityAssembler.new(PersonHavingAddressesWithIdAssembler.new(Assembler::EntityAssembler.new(AddressWithIdAssembler.new)))
    res
  end
  let(:person) { Person.new }
  let(:matcher) { AddressWithIdentityMappingMatcher.new(people_collection) }

  before do
    setup_connection
    person_repository.clear_everything!
  end

  describe 'one' do
    let(:work_address) { AddressWithId.new('Work street') }

    describe 'insert' do
      it 'puts embedded document to the parent document' do
        person.work_address = work_address
        person_repository.insert(person)
        matcher.assert_single_persisted(work_address)
      end
    end

    describe 'update' do
      it 'updates embedded document preserving id' do
        person.work_address = work_address
        person_repository.insert(person)
        work_address_original_id = work_address.id

        work_address.street = 'New street'
        person_repository.update(person)
        matcher.assert_single_persisted_with_given_id(work_address, work_address_original_id)
      end
    end

    describe 'find' do
      it 'returns domain object with related domain object' do
        person.work_address = work_address
        person_repository.insert(person)
        matcher.assert_single_loaded(
          work_address,
          person_repository.find(person.id).work_address
        )
      end
    end
  end

  describe 'many' do
    let(:address) { AddressWithId.new('street') }
    let(:address2) { AddressWithId.new('street2') }
    let(:address3) { AddressWithId.new('street3') }
    let(:address4) { AddressWithId.new('street4') }

    describe 'insert' do
      it 'puts embedded documents to the parent document' do
        person.add_address(address)
        person.add_address(address2)
        person_repository.insert(person)
        matcher.assert_persisted([address, address2])
      end
    end

    describe 'update' do
      describe 'updates embedded documents' do
        describe 'creates new' do
          it 'works if was empty' do
            person_repository.insert(person)
            person.add_address(address)
            person.add_address(address2)
            person_repository.update(person)
            matcher.assert_persisted([address, address2])
          end

          it 'works if was not empty, preserving ids' do
            person.add_address(address)
            person_repository.insert(person)
            address_original_id = address.id

            person.add_address(address2)
            person_repository.update(person)

            matcher.assert_persisted([address, address2])
            matcher.assert_the_same_id(address, address_original_id)
          end
        end

        it 'deletes removed' do
          [address, address2, address3, address4].each do |address|
            person.add_address(address)
          end
          person_repository.insert(person)
          person.remove_address(address)
          person.remove_address(address3)
          person_repository.update(person)

          matcher.assert_persisted([address2, address4])
        end

        it 'updates existing, preserving ids' do
          person.add_address(address)
          person_repository.insert(person)
          original_id = address.id

          address.street = 'new_street'
          person_repository.update(person)

          matcher.assert_persisted([address])
          matcher.assert_the_same_id(address, original_id)
        end
      end
    end

    describe 'find' do
      it 'returns domain object with related domain objects' do
        person.add_address(address)
        person.add_address(address2)
        person_repository.insert(person)

        matcher.assert_loaded([address, address2], person_repository.find(person.id).addresses)
      end
    end
  end
end
end end
