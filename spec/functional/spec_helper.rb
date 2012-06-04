require_relative '../spec_helper'
require_relative '../test/fake_clock'
require_relative '../test/mapping_matcher'

def setup_connection
  @connection = Mongo::Connection.new
  @db = @connection.db('testing')
end
