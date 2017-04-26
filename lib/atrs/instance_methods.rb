# frozen_string_literal: true

module Atrs
  module InstanceMethods
    def initialize(**hash)
      # raise "POC: More than one arg not supported..." if args.length > 1
      # kargs = args.first.merge(kargs) if args.any?
      _initialize { _atrs_init(hash) }
    end

    def _initializing?
      instance_variable_defined?(:@_initializing) && @_initializing
    end

    def _attribute_store
      _attribute_store_singleton || self.class.attribute_store
    end

    def _add_attribute(name, klass, **args, &blk)
      @_atrs_set_singleton = _attribute_store.add(name, klass, self.class, self.class.atrs_config, **args, &blk)
    end

    private

    def _initialize
      instance_variable_set(:@_initializing, true)
      yield
      remove_instance_variable(:@_initializing)
    end

    def _attribute_store_singleton
      @_atrs_set_singleton if instance_variable_defined?('@_atrs_set_singleton')
    end

    def _atrs_init(hash)
      _attribute_store.each do |name, atr|
        _attribute_init(atr, hash, name)
      end
    end

    def _attribute_init(atr, hash, name)
      send(atr.setter_name, hash[name])
    end
  end
end
