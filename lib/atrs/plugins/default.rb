# frozen_string_literal: true

module Atrs
  module Plugins
    module Default
      extend Atrs::Plugin

      Atrs.register_setter(
        name: :default_setter,
        priority: 5,
        use_if: ->(atr) { atr.options[:default] },
        setter: lambda do |value, atr, instance|
          if value && ![{},[]].include?(value)
            value
          else
            default = atr.default
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

      option :default, Boolean, setter: :default_setter
    end
  end
  register_plugin(:default, Plugins::Default)
end
