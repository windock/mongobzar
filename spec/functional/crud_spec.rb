require_relative 'spec_helper'
require 'mongobzar/repository/repository'
require 'mongobzar/mapper/entity_mapper'

module Mongobzar
  module Test
    class SimpleObject
      attr_accessor :id, :name, :description
    end

    class SimpleObjectMapper < Mapper::EntityMapper
      def build_domain_object!(simple_object, dto)
        simple_object.name = dto['name']
        simple_object.description = dto['description']
      end

      def build_dto!(dto, simple_object)
        dto['name'] = simple_object.name
        dto['description'] = simple_object.description
      end

      def build_new(dto)
        SimpleObject.new
      end
    end

    class SimpleObjectMappingMatcher < MappingMatcher
      def initialize(collection)
        @collection = collection
      end

      def assert_persisted(simple_objects)
        assert_correct_dtos_collection(simple_objects, @collection.find.to_a)
      end

      def assert_correct_dto(simple_object, dto)
        simple_object.id.should == dto['_id']
        simple_object.name.should == dto['name']
        simple_object.description.should == dto['description']
      end

      def assert_single_loaded(specification, simple_object)
        specification.id.should == simple_object.id
        specification.name.should == simple_object.name
        specification.description.should == simple_object.description
      end
    end
  end
end

include Mongobzar::Test
describe 'CRUD operations' do
  before do
    setup_connection
    @simple_objects_collection = @db.collection('simple_objects')
    @repository = Repository::Repository.new('testing', 'simple_objects')
    @repository.mapper = SimpleObjectMapper.new
    @repository.clear_everything!

    @so1 = SimpleObject.new
    @so1.name = 'name1'
    @so1.description = 'desc1'

    @so2 = SimpleObject.new
    @so2.name = 'desc2'
    @so2.description = 'desc2'
    @matcher = SimpleObjectMappingMatcher.new(@simple_objects_collection)
  end

  describe 'basic setup' do
    it 'shows informative error message if collection name is not provided' do
      pending
      class RepositoryWithoutCollection < Mongobzar::Repository::Repository
        def build_new(dto={})
        end
      end

      repository = RepositoryWithoutCollection.new('any_database_name')
      assert_raises('you should set mongo collection') do
        repository.insert(stub)
      end
    end

    it 'shows informative error message if build_new does not return object' do
      pending
      class RepositoryWithWrongBuildNew < Mongobzar::Repository::Repository
      end

      repository = RepositoryWithWrongBuildNew.new('any_database_name')
      assert_raises('build_new should return object with :id= method') do
      end
    end
  end

  describe 'insert' do
    it 'puts documents to mongo collection' do
      @repository.insert(@so1)
      @repository.insert(@so2)

      @matcher.assert_persisted([@so1, @so2])
    end

    it 'raises InvalidDomainObject if nil was passed' do
      #todo
    end
  end

  describe 'update' do
    it 'updates document' do
      @repository.insert(@so1)

      @so1.name = 'new_name'
      @repository.update(@so1)
      @matcher.assert_persisted([@so1])
    end
  end

  describe 'destroy' do
    it 'removes document from mongo collection' do
      @repository.insert(@so1)
      @repository.insert(@so2)

      @repository.destroy(@so1)
      @matcher.assert_persisted([@so2])
    end
  end

  describe 'all' do
    it 'returns all domain objects' do
      @repository.insert(@so1)
      @repository.insert(@so2)

      @matcher.assert_loaded([@so1, @so2], @repository.all)
    end
  end

  describe 'find' do
    it 'returns domain object by BSON::ObjectId' do
      @repository.insert(@so1)
      @repository.insert(@so2)

      found_so1 = @repository.find(@so1.id)
      found_so2 = @repository.find(@so2.id)

      @matcher.assert_loaded([@so1, @so2], [found_so1, found_so2])
    end

    it 'returns domain object by BSON::ObjectId as string' do
      @repository.insert(@so1)
      found_so1 = @repository.find(@so1.id.to_s)
      @matcher.assert_loaded([@so1], [found_so1])
    end

    it 'raises DocumentNotFound if document with such id was not found' do
      expect { @repository.find(BSON::ObjectId.new) }.to raise_error(Mongobzar::Repository::DocumentNotFound)
    end
  end

  it 'has no duplication with DependentRepository about collection management' do
    pending
  end
end
