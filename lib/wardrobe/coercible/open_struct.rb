# frozen_string_literal: true

require 'ostruct'
require_relative 'instance_coercer/open_struct'

module Wardrobe
  module Coercible
    add_coercer(NilClass => OpenStruct)   { OpenStruct.new }
    add_coercer(OpenStruct => OpenStruct) { |v| v }
    add_coercer(Hash => OpenStruct)       { |v| OpenStruct.new(v) }

    add_coercer(NilClass => OpenStruct.new) do |v, klass, parent, atr|
      InstanceCoercer::OpenStruct.init({}, klass, parent, atr)
    end

    add_coercer(Hash => OpenStruct.new) do |v, klass, parent, atr|
      InstanceCoercer::OpenStruct.init(v, klass, parent, atr)
    end
  end
end
