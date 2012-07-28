require_relative 'spec_helper'
require 'mongobzar/repository/repository'
require 'mongobzar/assembler/entity_assembler'
require 'mongobzar/utility/virtual_proxy'

module Mongobzar module Test
  class Main
    attr_accessor :id, :ref
  end

  class Ref
    attr_accessor :id, :main
  end

  class MainAssembler < Assembler::Assembler
    attr_accessor :ref_source

    def build_new(dto)
      Main.new
    end

    def build_domain_object!(obj, dto)
      obj.ref = Utility::VirtualProxy.new -> do
        ref_source.for_main(obj.id)
      end
    end
  end

  class RefAssembler < Assembler::Assembler
    attr_accessor :main_source

    def build_new(dto)
      Ref.new
    end

    def build_domain_object!(obj, dto)
      main = main_source.find(dto['main_id'])
      main.ref = obj
      obj.main = main
    end

    def build_dto!(dto, obj)
      dto['main_id'] = obj.main.id
    end
  end

  class RefRepository < Repository::Repository
    def for_main(main_id)
      assembler.build_domain_object(
        mongo_collection.find_one('main_id' => main_id))
    end
  end

  describe 'Two-way associations' do
    before do
      setup_connection
    end

    context 'having 2 objects storing references to each other' do
      before do
        main_assembler = MainAssembler.new

        ref_assembler = RefAssembler.new

        @main_rep = Repository::Repository.new('testing', 'mains')
        @main_rep.assembler = Assembler::EntityAssembler.new(
          main_assembler)

        @ref_rep = RefRepository.new('testing', 'refs')
        @ref_rep.assembler = Assembler::EntityAssembler.new(
          ref_assembler)

        ref_assembler.main_source = main_rep
        main_assembler.ref_source = ref_rep

        @main_rep.clear_everything!
        @ref_rep.clear_everything!
      end

      let(:ref_rep) { @ref_rep }
      let(:main_rep) { @main_rep }

      before do
        main.ref = ref
        ref.main = main
      end

      let(:main) { Main.new }
      let(:ref) { Ref.new }

      let(:persisted_ref_doc) do
        @db.collection('refs').find.to_a.first
      end

      context 'when main is already persisted' do
        before do
          main_rep.insert(main)
        end

        describe 'inserting ref' do
          it 'persists it with foreign key' do
            ref_rep.insert(ref)

            persisted_ref_doc['main_id'].should == main.id
          end
        end

        context 'when ref is persisted' do
          before do
            ref_rep.insert(ref)
          end

          describe 'loading ref' do
            describe 'loads ref with main with references' do
              let(:found_ref) { ref_rep.find(ref.id) }
              let(:found_main) { found_ref.main }

              subject { found_main }

              its(:id) { should == main.id }
              its('ref.id') { should == found_ref.id }
            end
          end

          describe 'loading main' do
            describe 'loads main with ref with references' do
              let(:found_main) { main_rep.find(main.id) }
              let(:found_ref) { found_main.ref }

              subject { found_ref }

              its(:id) { should == ref.id }
            end
          end
        end
      end
    end
  end
end end
