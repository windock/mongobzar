require_relative 'spec_helper'
require 'mongobzar/repository/repository'
require 'mongobzar/repository/dependent_repository'
require 'mongobzar/assembler/value_object_assembler'
require 'mongobzar/assembler/entity_assembler'

module Mongobzar
  module Test
    class Owner
      attr_accessor :id
      attr_reader :pets

      def initialize
        @pets = []
      end

      def add_pet(pet)
        @pets << pet
      end

      def remove_pet(pet)
        @pets.delete(pet)
      end
    end

    class Pet
      attr_accessor :id, :name, :created_at
      def initialize(name=nil)
        @name = name
      end
    end

    class OwnerAssembler < Assembler::Assembler
      def initialize(pet_repository)
        @pet_repository = pet_repository
      end

      def build_new(dto)
        Owner.new
      end

      def build_domain_object!(owner, dto)
        @pet_repository.find_dependent_collection(owner).each do |pet|
          owner.add_pet(pet)
        end
      end
    end

    class OwnerRepository < Mongobzar::Repository::Repository
      attr_accessor :pet_repository

      def insert(owner)
        super
        pet_repository.insert_dependent_collection(owner, owner.pets)
      end

      def update(owner)
        super
        pet_repository.update_dependent_collection(owner, owner.pets)
      end

      def clear_everything!
        super
        pet_repository.clear_everything!
      end

    end

    class PetAssembler < Assembler::Assembler
      def build_new(dto={})
        Pet.new
      end

      def build_domain_object!(pet, pet_dto)
        pet.name = pet_dto['name']
      end

      def build_dto!(dto, pet)
        dto['name'] = pet.name
      end
    end

    class PetRepository < Mongobzar::Repository::DependentRepository
      def foreign_key
        'owner_id'
      end
    end

    class PetMappingMatcher < MappingMatcher
      def initialize(collection)
        @collection = collection
      end

      def assert_dependent_persisted(pets, owner)
        assert_correct_dependent_dtos(pets, owner, @collection.find.to_a)
      end

      def assert_correct_dependent_dto(pet, owner, pet_dto)
        pet.id.should == pet_dto['_id']
        pet.name.should == pet_dto['name']
        owner.id.should == pet_dto['owner_id']
      end

      def assert_single_loaded(specification, pet)
        pet.id.should == specification.id
        pet.name.should == specification.name
      end
    end
  end
end

module Mongobzar module Test
describe 'Dependent association' do
  let(:the_only_pet_document) { pets_collection.find.to_a[0] }
  let(:owner_repository) do
    res = OwnerRepository.new('testing', 'owners')
    pet_repository = PetRepository.new('testing', 'pets')
    pet_repository.assembler = Assembler::EntityAssembler.new(PetAssembler.new)
    res.pet_repository = pet_repository
    res.assembler = Assembler::EntityAssembler.new(OwnerAssembler.new(pet_repository))
    res
  end
  let(:pets_collection) { @db.collection('pets') }
  let(:owner) { Owner.new }
  let(:owner2) { Owner.new }
  let(:pet)  { Pet.new('pet1') }
  let(:pet2) { Pet.new('pet2') }
  let(:pet3) { Pet.new('pet3') }
  let(:pet4) { Pet.new('pet4') }
  let(:matcher) { PetMappingMatcher.new(pets_collection) }

  before do
    setup_connection
    owner_repository.clear_everything!
  end

  describe 'insert' do
    it 'puts dependent documents to separate collection' do
      owner.add_pet(pet)
      owner.add_pet(pet2)
      owner_repository.insert(owner)
      matcher.assert_dependent_persisted([pet, pet2], owner)
    end
  end

  describe 'update' do
    describe 'updates dependent documents in separate collection' do
      describe 'creates new' do
        it 'works if was empty' do
          owner_repository.insert(owner)

          owner.add_pet(pet)
          owner.add_pet(pet2)

          owner_repository.update(owner)
          matcher.assert_dependent_persisted([pet, pet2], owner)
        end

        it 'works if was not empty' do
          owner.add_pet(pet)
          owner_repository.insert(owner)

          owner.add_pet(pet2)
          owner_repository.update(owner)
          matcher.assert_dependent_persisted([pet, pet2], owner)
        end
      end

      it 'deletes removed' do
        [pet, pet2, pet3, pet4].each do |pet|
          owner.add_pet(pet)
        end
        owner_repository.insert(owner)

        [pet2, pet4].each do |pet|
          owner.remove_pet(pet)
        end
        owner_repository.update(owner)
        matcher.assert_dependent_persisted([pet, pet3], owner)
      end

      it 'updates existing' do
        owner.add_pet(pet)
        owner_repository.insert(owner)

        pet.name = 'new_name'
        owner_repository.update(owner)
        matcher.assert_dependent_persisted([pet], owner)
      end
    end

    describe 'find' do
      it 'returns domain object with dependent domain objects' do
        owner.add_pet(pet)
        owner.add_pet(pet2)

        owner2.add_pet(pet3)

        owner_repository.insert(owner)
        owner_repository.insert(owner2)

        matcher.assert_loaded([pet, pet2], owner_repository.find(owner.id).pets)
      end
    end
  end
end
end end
