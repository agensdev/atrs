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

  def test_default_callback
    Class.new do
      include Wardrobe
      plugin :unknown_attributes
    end.new(missing: :atr)
  rescue Wardrobe::Plugins::UnknownAttributes::UnknownAttributesError => e
    assert_equal :atr, e.unknown_attributes[:missing]
  end

  def test_class_without_callback
    assert_raises(Wardrobe::MisconfiguredPluginError) do
      Class.new do
        include Wardrobe
        plugin :unknown_attributes, callback: 'invalid'
      end
    end
  end
end
