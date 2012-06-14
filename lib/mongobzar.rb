require "mongobzar/version"

module Mongobzar
  # Your code goes here...
end

require 'mongobzar/mapping/dependent_mapper'
require 'mongobzar/mapping/document_not_found'
require 'mongobzar/mapping/has_created_at'
require 'mongobzar/mapping/mapped_collection'
require 'mongobzar/mapping/mapper'
require 'mongobzar/mapping/embedded_with_identity_mapper'
require 'mongobzar/mapping/embedded_mapper'

require 'mongobzar/bson_id_generator'
