module Measurable
  module Minkowski
    # call-seq:
    #     minkowski(u, v) -> Numeric
    #     minkowski(u, v, p) -> Numeric
    #
    # Calculate the Minkowski distance of order +p+ between +u+ and +v+:
    #
    #   (sum |u_i - v_i|**p) ** (1/p)
    #
    # +p+ = 1 (the default) is the city-block, or Manhattan, distance; +p+ = 2
    # is the Euclidean distance; +p+ = Float::INFINITY is the Chebyshev
    # distance, max |u_i - v_i|. For +p+ >= 1 this is a metric. For
    # 0 < +p+ < 1 it is still defined, but the triangle inequality fails, so
    # it is not a metric.
    #
    # For +p+ other than 1 and infinity, the differences are scaled by the
    # largest before being raised to the power +p+, so the result neither
    # overflows nor underflows where the plain sum of powers would.
    #
    # See: https://en.wikipedia.org/wiki/Minkowski_distance
    #
    # Arguments:
    # - +u+ -> An array of Numeric objects.
    # - +v+ -> An array of Numeric objects.
    # - +p+ -> (Optional) The order, a positive number. Defaults to 1.
    # Returns:
    # - The Minkowski distance of order +p+ between +u+ and +v+. With the
    #   default +p+ = 1 and Integer inputs, the result is an Integer.
    # Raises:
    # - +ArgumentError+ -> The sizes of +u+ and +v+ don't match.
    # - +ArgumentError+ -> +p+ is not a positive number.
    def minkowski(u, v, p = 1)
      # TODO: Change this to a more specific, custom-made exception.
      raise ArgumentError if u.size != v.size
      unless p.is_a?(Numeric) && p.real? && p.positive?
        raise ArgumentError, "order p must be a positive number, got #{p.inspect}"
      end

      differences = u.zip(v).map { |a, b| (a - b).abs }
      # Left-to-right, as before; Array#sum would compensate and change the
      # last bit of existing results. See the Performance/Sum backlog item.
      return differences.reduce(0, :+) if p == 1 # rubocop:disable Performance/Sum

      largest = differences.max || 0
      return largest if p == Float::INFINITY
      return largest.to_f if largest.zero? || largest.infinite?

      scaled = differences.reduce(0.0) { |acc, d| acc + ((d / largest.to_f)**p) }
      largest * (scaled**(1.0 / p))
    end

    def self.extended(base) # :nodoc:
      base.instance_eval do
        alias :cityblock :minkowski
        alias :manhattan :minkowski
      end
      super
    end

    def self.included(base) # :nodoc:
      base.class_eval do
        alias_method :cityblock, :minkowski
        alias_method :manhattan, :minkowski
      end
      super
    end
  end

  extend Measurable::Minkowski
end
