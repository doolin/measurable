require 'measurable/euclidean'

module Measurable
  module Cosine
    # call-seq:
    #     cosine_similarity(u, v) -> Float
    #
    # Calculate the cosine similarity between the orientation of two vectors.
    #
    # See: http://en.wikipedia.org/wiki/Cosine_similarity
    #
    # Arguments:
    # - +u+ -> An array of Numeric objects.
    # - +v+ -> An array of Numeric objects.
    # Each vector is normalized first, with its norm computed by scaling to
    # the largest component, so huge or tiny components neither overflow nor
    # underflow. The result is clamped to [-1, 1], which rounding could
    # otherwise pass. A zero vector has no direction; the result is NaN.
    #
    # Returns:
    # - The normalized dot product of +u+ and +v+, that is, the cosine of the
    #   angle between them in the n-dimensional space, in [-1, 1].
    # Raises:
    # - +ArgumentError+ -> The sizes of +u+ and +v+ don't match.
    #
    def cosine_similarity(u, v)
      # TODO: Change this to a more specific, custom-made exception.
      raise ArgumentError if u.size != v.size

      a = cosine_unit_vector(u)
      b = cosine_unit_vector(v)
      return Float::NAN if a.nil? || b.nil?

      a.zip(b).reduce(0.0) { |acc, (x, y)| acc + (x * y) }.clamp(-1.0, 1.0)
    end

    # call-seq:
    #     cosine_distance(u, v) -> Float
    #
    # Calculate the cosine distance between the orientation of two vectors.
    #
    # See: http://en.wikipedia.org/wiki/Cosine_similarity
    #
    # Arguments:
    # - +u+ -> An array of Numeric objects.
    # - +v+ -> An array of Numeric objects.
    # Equal to 1 - cosine_similarity(u, v) in exact arithmetic, but computed
    # as |a - b|**2 / 2 for the unit vectors a and b. Subtracting a
    # similarity near 1 from 1 cancels: for nearly parallel vectors it
    # returns 0 or a few correct digits. This form keeps full relative
    # accuracy there, and it is never negative.
    #
    # Returns:
    # - One minus the cosine of the angle between +u+ and +v+, in [0, 2].
    #   NaN if either is a zero vector.
    # Raises:
    # - +ArgumentError+ -> The sizes of +u+ and +v+ don't match.
    def cosine_distance(u, v)
      # TODO: Change this to a more specific, custom-made exception.
      raise ArgumentError if u.size != v.size

      a = cosine_unit_vector(u)
      b = cosine_unit_vector(v)
      return Float::NAN if a.nil? || b.nil?

      (a.zip(b).reduce(0.0) { |acc, (x, y)| acc + ((x - y)**2) } / 2).clamp(0.0, 2.0)
    end

    def self.extended(base) # :nodoc:
      base.instance_eval do
        extend Measurable::Euclidean
      end
      super
    end

    def self.included(base) # :nodoc:
      base.class_eval do
        include Measurable::Euclidean
      end
      super
    end

    private

    # +u+ scaled to unit length, or nil for a zero vector. The norm is taken
    # as m * sqrt(sum (x/m)**2), with m the largest |x|, so it is finite for
    # any finite +u+.
    def cosine_unit_vector(u)
      largest = u.map { |x| x.abs.to_f }.max
      return nil if largest.nil? || largest.zero?

      scaled = u.map { |x| x / largest }
      norm = Math.sqrt(scaled.reduce(0.0) { |acc, x| acc + (x * x) })
      scaled.map { |x| x / norm }
    end
  end

  extend Measurable::Cosine
end
