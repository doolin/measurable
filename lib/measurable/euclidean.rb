module Measurable
  module Euclidean
    # call-seq:
    #     euclidean(u) -> Float
    #     euclidean(u, v) -> Float
    #
    # Calculate the ordinary distance between arrays +u+ and +v+.
    #
    # If +v+ isn't given, calculate the Euclidean norm of +u+.
    #
    # See: http://en.wikipedia.org/wiki/Euclidean_distance#N_dimensions
    #
    # Arguments:
    # - +u+ -> An array of Numeric objects.
    # - +v+ -> (Optional) An array of Numeric objects.
    # Returns:
    # - The euclidean norm of +u+ or the euclidean distance between +u+ and +v+.
    # Raises:
    # - +ArgumentError+ -> The sizes of +u+ and +v+ don't match.
    def euclidean(u, v = nil)
      sum = euclidean_squared(u, v)
      # The plain sum of squares is exact enough unless it overflowed or is
      # small enough for subnormal rounding to matter. The comparison is
      # false for NaN, so NaN still propagates.
      return euclidean_scaled(u, v) if sum.infinite? || sum < SMALLEST_SAFE_SQUARE_SUM

      Math.sqrt(sum)
    end

    # call-seq:
    #     euclidean_squared(u) -> Float
    #     euclidean_squared(u, v) -> Float
    #
    # Calculate the same value as euclidean(u, v), but don't take the square root
    # of it.
    #
    # This isn't a metric in the strict sense, i.e. it doesn't respect the
    # triangle inequality. However, the squared Euclidean distance is very useful
    # whenever only the relative values of distances are important, for example
    # in optimization problems.
    #
    # See: http://en.wikipedia.org/wiki/Euclidean_distance#Squared_Euclidean_distance
    #
    # Arguments:
    # - +u+ -> An array of Numeric objects.
    # - +v+ -> (Optional) An array of Numeric objects.
    # Returns:
    # - The squared value of the euclidean norm of +u+ or of the euclidean
    #   distance between +u+ and +v+.
    # Raises:
    # - +ArgumentError+ -> The sizes of +u+ and +v+ don't match.
    def euclidean_squared(u, v = nil)
      # If the second argument is nil, the method should return the norm of
      # vector u. For this, we need the distance between u and the origin.
      v = Array.new(u.size, 0) if v.nil?

      # TODO: Change this to a more specific, custom-made exception.
      raise ArgumentError if u.size != v.size

      u.zip(v).reduce(0.0) do |acc, ary|
        acc + ((ary[0] - ary[-1])**2)
      end
    end

    # Below this, a sum of squares may carry subnormal rounding, which is
    # absolute and so not small relative to the sum. Above it, that rounding
    # is below epsilon squared relative to the sum.
    SMALLEST_SAFE_SQUARE_SUM = Float::MIN / Float::EPSILON

    private

    # m * sqrt(sum (d/m)**2), with m the largest |d|: finite and accurate for
    # any finite input whose distance is representable.
    def euclidean_scaled(u, v)
      v = Array.new(u.size, 0) if v.nil?
      differences = u.zip(v).map { |a, b| (a - b).abs }
      largest = (differences.max || 0).to_f
      return largest if largest.zero? || largest.infinite?

      sum = differences.reduce(0.0) do |acc, d|
        q = d / largest
        acc + (q * q)
      end
      largest * Math.sqrt(sum)
    end
  end

  extend Measurable::Euclidean
end
