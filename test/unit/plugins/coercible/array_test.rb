require 'test_helper'

class ArrayCoercionTest < TestBase
  class Person
    include Wardrobe
    attribute :name, String
  end

  class ArrayObject
    include Wardrobe
    attribute :set,                       Array
    attribute :array,                     Array
    attribute :array_integer,             Array[Integer]
    attribute :array_string,              Array[String]
    attribute :array_hash,                Array[Hash]
    attribute :array_hash_integer_symbol, Array[Hash[Integer => Symbol]]
    attribute :array_wardrobe_objects,    Array[Person]
    attribute :array_wardrobe_self,       Array[ArrayObject]
    attribute :nil,                       Array
  end

  def setup
    @object = ArrayObject.new(
      set: Set.new([1,2]),
      array: [3,4],
      array_integer: ['1', '2.0', 3, 4.3],
      array_string: [1, 2.0, '3'],
      array_hash: [{one: '1'}, ['two', 2.4]],
      array_hash_integer_symbol: [{1.0 => 'one'}, ['2', 'two']],
      array_wardrobe_objects: [{name: 'Test Person'}],
      array_wardrobe_self: [{array_integer: ['1']}],
      nil: nil
    )
  end

  def test_coercion
    assert_equal [1,2], @object.set
    assert_equal [3,4], @object.array
    assert_equal [1,2,3,4], @object.array_integer
    assert_equal ['1','2.0','3'], @object.array_string
    assert_equal [{one: '1'}, {'two' => 2.4}], @object.array_hash
    assert_equal [{1 => :one}, {2 => :two}], @object.array_hash_integer_symbol
    assert Person === @object.array_wardrobe_objects[0]
    assert ArrayObject === @object.array_wardrobe_self[0]
    assert_equal [], @object.nil
  end

  def test_array_with_multiple_items
    assert_raises(StandardError) do
      Class.new do
        include Wardrobe
        attribute :array, Array[Integer, Hash]
      end
    end
  end

  def test_coercion_when_modifying_person_array
    @object.array_wardrobe_objects << { name: '1' }
    assert '1' === @object.array_wardrobe_objects[1].name
    assert Person === @object.array_wardrobe_objects[1]

    @object.array_wardrobe_objects.push(name: '2')
    assert '2' === @object.array_wardrobe_objects[2].name
    assert Person === @object.array_wardrobe_objects[2]

    @object.array_wardrobe_objects.unshift(name: '3')
    assert '3' === @object.array_wardrobe_objects[0].name
    assert Person === @object.array_wardrobe_objects[0]

    @object.array_wardrobe_objects.insert(-1, name: '4')
    assert '4' === @object.array_wardrobe_objects[4].name
    assert Person === @object.array_wardrobe_objects[4]

    assert_equal 5, @object.array_wardrobe_objects.count
    assert @object.array_wardrobe_objects.all? { |item| Person === item }
  end

  def test_coercion_return_value
    @object.array_integer << '5'
    @object.array_string << 4.1
    @object.array_hash_integer_symbol << { '3.1' => 'three' }
    assert_equal 5, @object.array_integer.last
    assert_equal '4.1', @object.array_string.last
    assert_equal({ 3 => :three }, @object.array_hash_integer_symbol.last)
  end

  def test_error
    assert_raises Wardrobe::Coercible::UnsupportedError do
      ArrayObject.new(set: :symbol)
    end
  end
end
