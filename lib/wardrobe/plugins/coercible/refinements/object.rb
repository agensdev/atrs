# frozen_string_literal: true

module Wardrobe
  module Plugins
    module Coercible
      module Refinements
        refine Object.singleton_class do
          def coerce(v, _atr, _parent)
            new(v)
          end
        end
      end
    end
  end
end
