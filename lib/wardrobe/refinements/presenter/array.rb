# frozen_string_literal: true

module Wardrobe
  module Refinements
    module Presenter
      refine Array do
        def _present(attributes: nil, **options)
          if attributes&.dig(:_)
            attributes = attributes.dup
            attributes.delete(:_)
          end

          map do |item|
            item._present(attributes: attributes, **options)
          end
        end
      end
    end
  end
end
