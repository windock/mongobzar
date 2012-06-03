require 'rr'
require 'ruby-debug'
require 'minitest/autorun'

class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end
