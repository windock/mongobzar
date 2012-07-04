require "mongobzar/version"

module Mongobzar
  # Your code goes here...
end

require 'mongobzar/mapper/dependent_mapper'
require 'mongobzar/mapper/document_not_found'
require 'mongobzar/mapper/mapper'

require 'mongobzar/mapping_strategy/entity_mapping_strategy'
require 'mongobzar/mapping_strategy/value_object_mapping_strategy'
require 'mongobzar/mapping_strategy/simple_mapping_strategy'
require 'mongobzar/mapping_strategy/polymorphic_mapping_strategy'

require 'mongobzar/utility/mapped_collection'
require 'mongobzar/utility/bson_id_generator'
