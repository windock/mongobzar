require_relative 'spec_helper'
require_relative '../../lib/mongobzar/mapping/mapper'

module Mongobzar
  module Test
    class SimpleObject
      attr_accessor :id, :name, :description
    end

    class SimpleObjectMapper < Mongobzar::Mapping::Mapper
      def initialize(database_name)
        super
        set_mongo_collection('simple_objects')
      end

      def build_new(dto={})
        SimpleObject.new
      end

      def build_domain_object!(simple_object, dto)
        simple_object.name = dto['name']
        simple_object.description = dto['description']
      end

      def build_dto!(dto, simple_object)
        dto['name'] = simple_object.name
        dto['description'] = simple_object.description
      end
    end

    class SimpleObjectMappingMatcher < MappingMatcher
      def assert_single_persisted(simple_object, dto)
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
    @connection = Mongo::Connection.new
    @db = @connection.db('testing')
    @simple_objects_collection = @db.collection('simple_objects')
    @mapper = SimpleObjectMapper.new('testing')
    @mapper.clear_everything!

    @so1 = SimpleObject.new
    @so1.name = 'name1'
    @so1.description = 'desc1'

    @so2 = SimpleObject.new
    @so2.name = 'desc2'
    @so2.description = 'desc2'
    @matcher = SimpleObjectMappingMatcher.new
  end

  def find_simple_object_documents
    @simple_objects_collection.find.to_a
  end

  describe 'insert' do
    it 'puts documents to mongo collection' do
      @mapper.insert(@so1)
      @mapper.insert(@so2)

      @matcher.assert_persisted([@so1, @so2], find_simple_object_documents)
    end

    it 'raises InvalidDomainObject if nil was passed' do
      #todo
    end
  end

  describe 'update' do
    it 'updates document' do
      @mapper.insert(@so1)

      @so1.name = 'new_name'
      @mapper.update(@so1)
      @matcher.assert_persisted([@so1], find_simple_object_documents)
    end
  end

  describe 'destroy' do
    it 'removes document from mongo collection' do
      @mapper.insert(@so1)
      @mapper.insert(@so2)

      @mapper.destroy(@so1)
      @matcher.assert_persisted([@so2], find_simple_object_documents)
    end
  end

  describe 'all' do
    it 'returns all domain objects' do
      @mapper.insert(@so1)
      @mapper.insert(@so2)

      @matcher.assert_loaded([@so1, @so2], @mapper.all)
    end
  end

  describe 'find' do
    it 'returns domain object by BSON::ObjectId' do
      @mapper.insert(@so1)
      @mapper.insert(@so2)

      found_so1 = @mapper.find(@so1.id)
      found_so2 = @mapper.find(@so2.id)

      @matcher.assert_loaded([@so1, @so2], [found_so1, found_so2])
    end

    it 'returns domain object by BSON::ObjectId as string' do
      @mapper.insert(@so1)
      found_so1 = @mapper.find(@so1.id.to_s)
      @matcher.assert_loaded([@so1], [found_so1])
    end

    it 'raises DocumentNotFound if document with such id was not found' do
      expect { @mapper.find(BSON::ObjectId.new) }.to raise_error(Mongobzar::Mapping::DocumentNotFound)
    end
  end
end
