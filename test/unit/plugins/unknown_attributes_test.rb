require 'test_helper'

class UnknownAttributesTest < TestBase
  class Foo
    include Wardrobe
    plugin :unknown_attributes, callback: ->(data,instance) { instance.unknown_attributes = data }
    attribute :bar, String
    attribute :unknown_attributes, Hash
  end


  def test_unknown_attributes
    instance = Foo.new(bar: 'Test', another: 'Attribute', unknown: 'value')
    assert_equal [:another, :unknown], instance.unknown_attributes.keys
  end
end