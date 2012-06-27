require_relative '../spec_helper'
require_relative '../../lib/mongobzar/mapping/mapped_collection'

include Mongobzar
class TestDomainObject
  attr_reader :id
  attr_reader :name

  def initialize(name, id=nil)
    @name = name
    @id = id
  end

  def ==(o)
    @name == o.name &&
    @id == o.id
  end

  def change_name(name)
    @name = name
  end
end

class TestDomainObjectMappingStrategy
  def initialize(id_generator)
    @id_generator = id_generator
  end

  def build_domain_object(dto)
    TestDomainObject.new(dto['name'], dto['_id'])
  end

  def build_dto(domain_object)
    dto = {}
    dto['_id'] = @id_generator.generate
    dto['name'] = domain_object.name
    dto
  end

  def update_dto!(dto, domain_object)
    dto['name'] = domain_object.name
  end
end

class IdGenerator
  def initialize(ids)
    @ids = ids
  end

  attr_writer :ids

  def generate
    id = @ids.first
    @ids.rotate!
    id
  end
end

def assert_same_dict(d1, d2)
  d1.size.should == d2.size
  d1.each do |key, value|
    matched_by_key = d2.detect { |k, v| k == key }
    matched_by_key.should_not be_nil
    d2_key = matched_by_key.first
    d1[key].should == d2[d2_key]
  end
end

def domain_object_with_id(name, id)
  TestDomainObject.new(name, id)
end

def domain_object_without_id(name)
  TestDomainObject.new(name)
end

describe Mongobzar::Mapping::MappedCollection do
  before do
    @id_generator = IdGenerator.new([1, 2])

    @dto1 = { '_id' => 1, 'name' => 'd1' }
    @dto2 = { '_id' => 2, 'name' => 'd2' }
    @dto3 = { '_id' => 3, 'name' => 'd3' }

    @mc = Mongobzar::Mapping::MappedCollection.new(
      TestDomainObjectMappingStrategy.new(@id_generator))
  end


  describe 'stateful collection' do
    describe 'when loaded with domain objects' do
      before do
        @d1 = domain_object_without_id('d1')
        @d2 = domain_object_without_id('d2')
        @mc.load_domain_objects([@d1, @d2])
      end

      it 'builds dtos from domain objects' do
        [@dto1, @dto2].should == @mc.dtos
      end

      it 'returns domain objects as were loaded' do
        [@d1, @d2].should == @mc.domain_objects
      end

      it 'builds dict' do
        expected_dict = { @d1 => @dto1, @d2 => @dto2 }
        expected_dict.should == @mc.dict
      end
    end

    describe 'when loaded with dtos' do
      before do
        @mc.load_dtos([@dto1, @dto2])
      end

      it 'buids domain objects from dtos' do
        [
          domain_object_with_id('d1', 1),
          domain_object_with_id('d2', 2)
        ].should == @mc.domain_objects
      end

      it 'returns dtos as were loaded' do
        [@dto1, @dto2].should == @mc.dtos
      end

      it 'builds dict' do
        dict = @mc.dict
        assert_same_dict({
          domain_object_with_id('d1', 1) => @dto1,
          domain_object_with_id('d2', 2) => @dto2
        }, dict)
      end
    end

    describe 'after update' do
      before do
        @d1 = domain_object_with_id('d1', 1)
        @d2 = domain_object_with_id('d2', 2)
        @d3_wid = domain_object_without_id('d3')
        @mc.load_dtos([@dto1, @dto2])
      end

      describe 'builds dtos for new' do
        before do
          @id_generator.ids = [3]
          @mc.update([@d1, @d2, @d3_wid])
        end

        it 'dtos' do
          [@dto1, @dto2, @dto3].should == @mc.dtos
        end

        it 'dict' do
          dict = @mc.dict
          {
            @d1 => @dto1,
            @d2 => @dto2,
            @d3_wid => @dto3
          }.should == dict
          @d3_wid.id.should be_nil
        end
      end

      describe 'removes dtos from missing' do
        before do
          @mc.update([@d1])
        end

        it 'dtos' do
          [@dto1].should == @mc.dtos
        end

        it 'dict' do
          { @d1 => @dto1 }.should == @mc.dict
        end
      end

      describe 'updates existing dtos with new data' do
        before do
          @expected_dto1 = { '_id' => 1, 'name' => 'new_d1' }
          @expected_dto2 = { '_id' => 2, 'name' => 'new_d2' }
          @d1.change_name('new_d1')
          @d2.change_name('new_d2')
          @mc.update([@d1, @d2])
        end

        it 'dtos' do
          [@expected_dto1, @expected_dto2].should == @mc.dtos
        end

        it 'dict' do
          { @d1 => @expected_dto1, @d2 => @expected_dto2 }.should == @mc.dict
        end
      end

      describe 'does adding/removing/updating at once' do
        before do
          @id_generator.ids = [3]
          initial_dtos = [@dto1, @dto2]
          @expected_dto1 = { '_id' => 2, 'name' => 'u2_new' }
          @expected_dto2 = { '_id' => 3, 'name' => 'd3' }
          @d2.change_name('u2_new')
          @mc.update([@d2, @d3_wid])
        end
        it 'dtos' do
          [@expected_dto1, @expected_dto2].should == @mc.dtos
        end

        it 'dict' do
          { @d2 => @expected_dto1, @d3_wid => @expected_dto2 }.should == @mc.dict
        end
      end

      #TODO
      # it 'adds dtos from domain object with id' do
      #   initial_dtos = [@dto1, @dto2]
      #   expected_dtos = [@dto1, @dto2, @dto3]
      #   @u3.id = 3
      #   assert_equal expected_dtos, @mc.updated_dtos(initial_dtos, [@u1, @u2, @u3])
      # end
    end
  end
end
