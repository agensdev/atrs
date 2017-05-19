# Wardrobe
[![Build Status](https://travis-ci.org/agensdev/wardrobe.svg?branch=master)](https://travis-ci.org/agensdev/wardrobe)
[![Code Climate](https://codeclimate.com/github/agensdev/wardrobe.svg)](https://codeclimate.com/github/agensdev/wardrobe)
[![Test Coverage](https://codeclimate.com/github/agensdev/wardrobe/badges/coverage.svg)](https://codeclimate.com/github/agensdev/wardrobe/coverage)
<!-- [![Gem Version](https://badge.fury.io/agensdev/wardrobe.svg)](https://rubygems.org/gems/wardrobe) -->

Wardrobe is a gem that simplifies creating Ruby objects with attributes. Wardrobe bundles a multitude of plugins. See [list](#bundled-plugins) below.

## Requirements

Wardrobe requires Ruby 2.4.0 or later. Read more about why [here](#ruby-24).
JRuby should be supported once [9.2.0.0](https://github.com/jruby/jruby/milestone/53) is released

## Installation

```
gem install wardrobe
```

## Getting started

```ruby
require 'wardrobe'

class User
  include Wardrobe
  attribute :name, String
end

User.new(name: 'Wardrobe User')
```

## Composition

Wardrobe allows you to compose models from multiple modules for easy reuse.

```ruby
module Name
  include Wardrobe
  attribute :first_name, String
  attribute :last_name, String
end

class Person
  include Name
  attribute :age, Integer
end
```

## Coercion

Coercion is enabled by default and works with most types available in Ruby.

Example:
```ruby
class User
  include Wardrobe
  attribute :id, Integer
  attribute :name, String
  attribute :status, Symbol
  attribute :friends, Array[User]
  attribute :interests, Hash[String => Symbol]
end

user = User.new(
  id: 1.1,
  name: :'Example User',
  status: 'active',
  friends: [
    {
      id: '0045',
      name: 'Another User',
      status: 'inactive'
    }
  ],
  interests: {
    'architecture' => 'medium',
    :sports => 'low',
    :travel => :high
  }
)

# <User:0x007fcc160851f8
#   @id=1,
#   @name="Example User",
#   @status=:active,
#   @friends=[
#     <User:0x007fcc16084b68
#       @id=45,
#       @name="Another User",
#       @status=:inactive,
#       @friends=[],
#       @interests={}>
#   ],
#   @interests={
#     "architecture"=>:medium,
#     "sports"=>:low,
#     "travel"=>:high
# }>
```

Coercion also works when mutating `Array`, `Hash` and `Set`. Based on the example above adding a friend to the friends array would coerce the given hash into a `User` object:

```ruby
user.friends << { id: '22', name: 'Added later' }
# => [
#  #<User:0x007fb242c0c960
#    @id=45,
#    @name="Another User",
#    @status=:inactive,
#    @friends=[],
#    @interests={}>,
#  #<User:0x007fb242bd66a8
#    @id=22,
#    @name="Added later",
#    @status=nil,
#    @friends=[],
#    @interests={}>
# ]
```
## Block syntax

Many plugins expose options for attributes. These can be enabled on each attribute needed, or you can use a block to enable for a group of attributes.

Per attribute syntax:
```ruby
class User
  include Wardrobe
  plugin :nil_if_empty

  attribute :first_name, String, nil_if_empty: true
  attribute :last_name, String, nil_if_empty: true
  attribute :friends, Array, nil_if_empty: true
end
User.new(first_name: '', last_name: '', friends: [])
# => #<User:0x007fb242b5e798 @friends=nil, @first_name=nil, @last_name=nil>
```

Block syntax:
```ruby
class User
  include Wardrobe
  plugin :nil_if_empty

  attributes do
    nil_if_empty true do
      attribute :first_name, String
      attribute :last_name, String
      attribute :friends, Array
    end
  end
end
User.new(first_name: '', last_name: '', friends: [])
# => #<User:0x007fb242b5e798 @friends=nil, @first_name=nil, @last_name=nil>
```

## Bundled Plugins

Wardrobe comes with numerous plugins and aims at making it easy to write your own.

|Name               |Exposed options      |Development state  |Description       |
|-------------------|---------------------|-------------------|------------------|
|validation         |`validates`          |BETA               |dry-validation and Hanami inspired validations for your attributes|
|immutable          |`immutable`          |BETA               |makes your object immutable. Exposes a #mutate method that will return a new immutable object|
|dirty_tracker      |`track`              |BETA               |tracks instances and exposes a #_changed? method|
|default            |`default`            |BETA               |default values for attributes|
|configurable       |                     |BETA               |allows you to add class level immutable configuration to your classes|
|nil_if_empty       |`nil_if_empty`       |BETA               |Converts empty objects like `''`, `{}` and `[]` to nil when initializing.|
|nil_if_zero        |`nil_if_zero`        |BETA               |
|alias_setters      |`alias_setter(Array)`|BETA               |
|optional_setter    |`setter`             |BETA               |disable the setter|
|optional_getter    |`getter`             |BETA               |disable the getter|
|equality           |`include_in_equality`|BETA               |check if to wardrobe instances are equal|
|presenter          |                     |POC                |presents your instance as a hash|
|json_initializer   |                     |POC                |initialize your model with a json string|
|html_initializer   |                     |POC                |initialize your model with a html string|
|xml_initializer    |                     |NOT IMPLEMENTED    |initialize your model with a xml string|

## Writing your own plugin

### Example

```ruby
require 'wardrobe'

Wardrobe.register_setter(
  name: :capitalize,
  priority: 25,
  use_if: ->(atr) { atr.options[:capitalize] && atr.klass == String },
  setter: lambda do |value, _atr, _instance|
    value ? value.capitalize : value
  end
)

module Capitalize
  extend Wardrobe::Plugin
  option :capitalize, Wardrobe::Boolean, setter: :capitalize
end

Wardrobe.register_plugin(:capitalize, Capitalize)

class Person
  include Wardrobe
  plugin :capitalize

  attribute :name, String, capitalize: true
  attribute :gender, String
end

Person.new(name: 'foo', gender: 'male')
#=> #<Person:0x007fba42a273b8 @name="Foo", @gender="male">
```

## Goals

Wardrobe should:

* be faster than Virtus
* have no dependencies (plugins may)
* not pollute the instance level with any methods other than ones prefixed with `_`
* should be immutable in the config layer allowing subclasses or singleton classes to modify the config
* be easy to extend with plugins
* simplify coercions through refinements

## Ruby 2.4

When working on the first "Proof of Concept" for Wardrobe I wanted to use refinements for coercion. This was right before Ruby 2.4 was released that added support for using Kernel#send to call a method defined in a refined class. This was needed to get my first POC working and is why Wardrobe requires ruby 2.4 or above.
