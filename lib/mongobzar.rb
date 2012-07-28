require "mongobzar/version"

module Mongobzar
  # Your code goes here...
end

require 'mongobzar/repository/dependent_repository'
require 'mongobzar/repository/document_not_found'
require 'mongobzar/repository/repository'

require 'mongobzar/assembler/entity_assembler'
require 'mongobzar/assembler/value_object_assembler'
require 'mongobzar/assembler/simple_assembler'
require 'mongobzar/assembler/polymorphic_assembler'

require 'mongobzar/utility/mapped_collection'
require 'mongobzar/utility/bson_id_generator'
require 'mongobzar/utility/virtual_proxy'
