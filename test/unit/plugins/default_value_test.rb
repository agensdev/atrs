require 'test_helper'

class DefaultValueTest < TestBase
  module DefaultMixin
    include Wardrobe
    plugin :default
    attribute :name,     String, default: 'missing name'
    attribute :address,  String, default: :address_default
    attribute :zip_code, String, default: proc { '0' + '1' }
    attribute :for_sale, Boolean, default: false
    attribute :for_rent, Boolean, default: true

    def address_default
      'missing address'
    end
  end

  class Foo
    include Wardrobe
    attribute :bar, String
  end

  class House
    include DefaultMixin
    attribute :floors,     Integer, default: 2
    attribute :bedrooms,   Integer, default: :bedrooms_default
    attribute :bathrooms,  Integer, default: proc { 1 + 3 }
    attribute :condition,  Symbol, default: :new
    attribute :no_default, String
    attribute :wardrobe,   Foo, default: proc { |_, atr| atr.klass.new(bar: 'Child') }

    def bedrooms_default
      10
    end
  end

  class HouseWithAddressDefaultOverride < House
    def address_default
      'overridden'
    end
  end

  def setup
    @house = House.new
  end

  def test_default_literal
    assert_equal 2, @house.floors
    assert_equal 'missing name', @house.name
  end

  def test_default_boolean
    assert_equal 3,House.attribute_store[:for_rent].setters.length
    assert_equal 3,House.attribute_store[:for_sale].setters.length
    assert_equal true, @house.for_rent
    assert_equal false, @house.for_sale
    @house.for_rent = false
    @house.for_sale = true
    assert_equal false, @house.for_rent
    assert_equal true, @house.for_sale
  end

  def test_default_symbol
    assert_equal 10, @house.bedrooms
    assert_equal 'missing address', @house.address
  end

  def test_default_proc
    assert_equal 4, @house.bathrooms
  end

  def test_symbol_default
    assert_equal :new, @house.condition
  end

  def test_no_default
    assert_nil @house.no_default
  end

  def test_default_method_override
    assert_equal 'overridden', HouseWithAddressDefaultOverride.new.address
  end

  def test_default_for_wardrobe_child
    assert_equal 'Child', @house.wardrobe.bar
  end
end
