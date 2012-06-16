require_relative 'spec_helper'
require_relative '../../lib/mongobzar/mapping/mapper'
require_relative '../../lib/mongobzar/mapping/has_created_at'

module Mongobzar
  module Test
    class TimestampedObject
      attr_accessor :id, :created_at
    end

    class TimestampedObjectMapper < Mongobzar::Mapping::Mapper
      include Mongobzar::Mapping::HasCreatedAt

      def mongo_collection_name
        'timestamped_objects'
      end

      def build_new(dto)
        TimestampedObject.new
      end
    end
  end
end

include Mongobzar::Test

describe 'timestamps' do
  def find_timestamped_objects
    @timestamped_objects_collection.find.to_a
  end

  before do
    setup_connection
    @timestamped_objects_collection = @db.collection('timestamped_objects')
    @mapper = Mongobzar::Test::TimestampedObjectMapper.new('testing')
    @mapper.clear_everything!
    @to1 = TimestampedObject.new
    @to2 = TimestampedObject.new
  end

  describe 'on insert' do
    it 'sets created_at for document' do
      @mapper.clock = FakeClock.frozen
      @mapper.insert(@to1)
      FakeClock.frozen.now.should == find_timestamped_objects[0]['created_at']
    end

    it 'sets created_at for domain object' do
      @mapper.clock = FakeClock.frozen
      @mapper.insert(@to1)
      FakeClock.frozen.now.should == @to1.created_at
    end
  end

  describe 'on update' do
    it 'doesn\t change created_at' do
      @mapper.clock = FakeClock.frozen
      @mapper.insert(@to1)
      @mapper.clock = FakeClock.different_frozen

      @mapper.update(@to1)
      FakeClock.frozen.now.should == find_timestamped_objects[0]['created_at']
    end
  end

  describe 'on find' do
    it 'sets created_at for domain object' do
      @mapper.clock = FakeClock.frozen
      @mapper.insert(@to1)

      FakeClock.frozen.now.should == @mapper.find(@to1.id).created_at
    end
  end
end
