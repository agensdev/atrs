require 'test_helper'

class NilIfEmptyTest < TestBase
  class Tree
    include Wardrobe
    plugin :nil_if_empty
    attribute :name,     String, nil_if_empty: true
    attribute :branches, Hash,   nil_if_empty: true
    attribute :leaves,   Array,  nil_if_empty: true
  end

  class TreeFalse
    include Wardrobe
    plugin :nil_if_empty
    attribute :name,     String, nil_if_empty: false
    attribute :branches, Hash,   nil_if_empty: false
    attribute :leaves,   Array,  nil_if_empty: false
  end

  def setup
    @tree = Tree.new(name: '', branches: {}, leaves: [])
    @tree_false = TreeFalse.new(name: '', branches: {}, leaves: [])
  end

  def test_string
    assert_nil @tree.name
    assert_equal '', @tree_false.name
  end

  def test_hash
    assert_nil @tree.branches
    assert_equal Hash.new, @tree_false.branches
  end

  def test_array
    assert_nil @tree.leaves
    assert_equal [], @tree_false.leaves
  end
end
