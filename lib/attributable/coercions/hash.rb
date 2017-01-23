module Attributable
  module Coercions
    refine Hash.singleton_class do
      def coerce(v, atr)
        case v
        when self then v
        when NilClass then {}
        else
          raise UnsupportedError
        end
      end
    end
    refine Hash do
      def coerce(v, atr)
        case v
        when Hash
          v.map do |key, value|
            [self.first[0].coerce(key), self.first[1].coerce(value)]
          end.to_h
        when NilClass then {}
        else
          raise UnsupportedError
        end
      end
    end
  end
end
