require "mongobzar/version"

module Mongobzar
  # Your code goes here...
end

require 'mongobzar/mapping/dependent_mapper'
require 'mongobzar/mapping/document_not_found'
require 'mongobzar/mapping/mapped_collection'
require 'mongobzar/mapping/mapper'

require 'mongobzar/mapping_strategy/entity_mapping_strategy'
require 'mongobzar/mapping_strategy/value_object_mapping_strategy'
require 'mongobzar/mapping_strategy/simple_mapping_strategy'
require 'mongobzar/mapping_strategy/polymorphic_mapping_strategy'

require 'mongobzar/bson_id_generator'
