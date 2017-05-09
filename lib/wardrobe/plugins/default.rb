# frozen_string_literal: true

module Wardrobe
  module Plugins
    module Default
      extend Wardrobe::Plugin

      Wardrobe.register_setter(
        name: :default_setter,
        priority: 5,
        use_if: ->(atr) { !atr.options[:default].nil? },
        setter: lambda do |value, atr, instance|
          if !value.nil? && ![{},[]].include?(value)
            value
          else
            default = atr.options[:default]
            case default
            when Symbol
              default.match?(/default$/) ? instance.send(default) : default
            when Proc
              default.arity.zero? ? default.call : default.call(instance)
            else
              default
            end
          end
        end
      )

      option :default, Object, setter: :default_setter
    end
  end
  register_plugin(:default, Plugins::Default)
end