require_relative 'spec_helper'
require_relative '../../lib/mongobzar/mapping/mapper'
require_relative '../../lib/mongobzar/mapping/dependent_mapper'
require_relative '../../lib/mongobzar/mapping/has_created_at'
require_relative '../../lib/mongobzar/mapping/mapping_strategy'
require_relative '../../lib/mongobzar/mapping/with_identity_mapping_strategy'

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
    end

    class OwnerMappingStrategy < Mapping::WithIdentityMappingStrategy
      def initialize(pet_mapper)
        @pet_mapper = pet_mapper
      end

      def build_new(dto)
        Owner.new
      end

      def build_domain_object!(owner, dto)
        @pet_mapper.find_dependent_collection(owner).each do |pet|
          owner.add_pet(pet)
        end
      end
    end

    class OwnerMapper < Mongobzar::Mapping::Mapper
      def initialize(database_name)
        super
        @clock = Time
        @pet_mapper = PetMapper.new(database_name)
      end

      def mongo_collection_name
        'owners'
      end

      attr_reader :clock
      def clock=(clock)
        @clock = @pet_mapper.clock = clock
      end

      def mapping_strategy
        OwnerMappingStrategy.new(@pet_mapper)
      end

      def insert(owner)
        super
        @pet_mapper.insert_dependent_collection(owner, owner.pets)
      end

      def update(owner)
        super
        @pet_mapper.update_dependent_collection(owner, owner.pets)
      end

      def clear_everything!
        super
        @pet_mapper.clear_everything!
      end
    end

    class PetMappingStrategy < Mapping::WithIdentityMappingStrategy
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

    class PetMapper < Mongobzar::Mapping::DependentMapper
      include Mongobzar::Mapping::HasCreatedAt

      def initialize(database_name)
        super
        self.foreign_key = 'owner_id'
      end

      def mongo_collection_name
        'pets'
      end

      def mapping_strategy
        PetMappingStrategy.new
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

include Mongobzar::Test
describe 'Dependent association' do
  def the_only_pet_document
    @pets_collection.find.to_a[0]
  end

  before do
    setup_connection
    @owners_collection = @db.collection('owners')
    @owner_mapper = OwnerMapper.new('testing')
    @owner_mapper.clear_everything!

    @pets_collection = @db.collection('pets')

    @owner = Owner.new
    @owner2 = Owner.new

    @pet, @pet2, @pet3, @pet4 = 1.upto(4).map do |i|
      pet = Pet.new
      pet.name = "pet#{i}"
      pet
    end
    @matcher = PetMappingMatcher.new(@pets_collection)
  end

  describe 'timestamps' do
    before do
      @owner.add_pet(@pet)
    end

    describe 'on insert' do
      it 'sets created_at for document' do
        @owner_mapper.clock = FakeClock.frozen
        @owner_mapper.insert(@owner)
        FakeClock.frozen.now.should == the_only_pet_document['created_at']
      end

      it 'ets created_at for domain_object' do
        @owner_mapper.clock = FakeClock.frozen
        @owner_mapper.insert(@owner)
        FakeClock.frozen.now.should == @pet.created_at
      end

      it 'sets the same created-at for both domain object and document' do
        @owner_mapper.clock = FakeClock.changes_year
        @owner_mapper.insert(@owner)
        the_only_pet_document['created_at'].should == @pet.created_at
      end
    end

    describe 'on update' do
      it 'doesn\'t change created_at' do
        @owner_mapper.clock = FakeClock.frozen
        @owner_mapper.insert(@owner)
        @owner_mapper.clock = FakeClock.different_frozen

        @pet.name = 'whatever'
        @owner_mapper.update(@owner)
        FakeClock.frozen.now.should == the_only_pet_document['created_at']
      end
    end

    describe 'on find' do
      it 'sets created_at for domain object' do
        @owner_mapper.clock = FakeClock.frozen
        @owner_mapper.insert(@owner)

        FakeClock.frozen.now.should == @owner_mapper.find(@owner.id).pets[0].created_at
      end
    end
  end

  describe 'insert' do
    it 'puts dependent documents to separate collection' do
      @owner.add_pet(@pet)
      @owner.add_pet(@pet2)
      @owner_mapper.insert(@owner)
      @matcher.assert_dependent_persisted([@pet, @pet2], @owner)
    end
  end

  describe 'update' do
    describe 'updates dependent documents in separate collection' do
      describe 'creates new' do
        it 'works if was empty' do
          @owner_mapper.insert(@owner)

          @owner.add_pet(@pet)
          @owner.add_pet(@pet2)

          @owner_mapper.update(@owner)
          @matcher.assert_dependent_persisted([@pet, @pet2], @owner)
        end

        it 'works if was not empty' do
          @owner.add_pet(@pet)
          @owner_mapper.insert(@owner)

          @owner.add_pet(@pet2)
          @owner_mapper.update(@owner)
          @matcher.assert_dependent_persisted([@pet, @pet2], @owner)
        end
      end

      it 'deletes removed' do
        [@pet, @pet2, @pet3, @pet4].each do |pet|
          @owner.add_pet(pet)
        end
        @owner_mapper.insert(@owner)

        [@pet2, @pet4].each do |pet|
          @owner.remove_pet(pet)
        end
        @owner_mapper.update(@owner)
        @matcher.assert_dependent_persisted([@pet, @pet3], @owner)
      end

      it 'updates existing' do
        @owner.add_pet(@pet)
        @owner_mapper.insert(@owner)

        @pet.name = 'new_name'
        @owner_mapper.update(@owner)
        @matcher.assert_dependent_persisted([@pet], @owner)
      end
    end

    describe 'find' do
      it 'returns domain object with dependent domain objects' do
        @owner.add_pet(@pet)
        @owner.add_pet(@pet2)

        @owner2.add_pet(@pet3)

        @owner_mapper.insert(@owner)
        @owner_mapper.insert(@owner2)

        @matcher.assert_loaded([@pet, @pet2], @owner_mapper.find(@owner.id).pets)
      end
    end
  end
end
