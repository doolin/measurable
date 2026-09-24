module Measurable
  # Earth radius in kilometers (mean radius, rounded). Some algorithms use 6367.
  # Every other unit is derived from this one, so results agree across units.
  EARTH_RADIUS_IN_KILOMETERS = 6371

  # Kilometers per international mile (exact by definition).
  KILOMETERS_PER_MILE = 1.609344

  # Feet per mile (exact by definition).
  FEET_PER_MILE = 5280

  # Earth radius in miles, derived from the kilometer radius.
  EARTH_RADIUS_IN_MILES = EARTH_RADIUS_IN_KILOMETERS / KILOMETERS_PER_MILE

  # The great circle distance returned will be in whatever units R is in.
  EARTH_RADIUS = {
    miles: EARTH_RADIUS_IN_MILES,
    km: EARTH_RADIUS_IN_KILOMETERS,
    feet: EARTH_RADIUS_IN_MILES * FEET_PER_MILE,
    meters: EARTH_RADIUS_IN_KILOMETERS * 1000
  }.freeze

  module Haversine
    # call-seq:
    #     haversine(u, v) -> Float
    #
    # Compute accurate distances between two points given their latitudes and
    # longitudes, even for short distances. This isn't a distance measure in the
    # same sense as the other methods in +Measurable+.
    #
    # The distance returned is the great circle (or orthodromic) distance between
    # +u+ and +v+, which is the shortest distance between them on the surface of
    # a sphere. Thus, this implementation considers the Earth to be a sphere.
    #
    # Reminding that the input vectors are of the form [latitude, longitude] in
    # degrees, so if you have the coordinates [23 32' S, 46 37' W] (from São
    # Paulo), the corresponding vector is [-23.53333, -46.61667].
    #
    # References:
    # - http://www.movable-type.co.uk/scripts/latlong.html
    # - http://en.wikipedia.org/wiki/Haversine_formula
    # - http://en.wikipedia.org/wiki/Great-circle_distance
    #
    # Arguments:
    # - +u+ -> An array of Numeric objects.
    # - +v+ -> An array of Numeric objects.
    # - +unit+ -> (Optional) A Symbol representing the unit of measure. Available
    #             options are +:miles+, +:feet+, +:km+ and +:meters+.
    # - +formula+ -> (Optional) +:split+ (the default) or +:classic+. Both
    #                compute the haversine a; they differ in how they get 1 - a.
    #                +:classic+ subtracts, which near antipodal points leaves
    #                only half the digits: an error of about sqrt(epsilon)
    #                times the distance, some centimeters on the Earth.
    #                +:split+ writes a and 1 - a each as a sum of squares, with
    #                no cancellation, and is accurate to a few ulps everywhere.
    # Returns:
    # - The great circle distance between +u+ and +v+.
    # Raises:
    # - +ArgumentError+ -> The size of +u+ and +v+ must be 2.
    # - +ArgumentError+ -> +unit+ must be a Symbol.
    # - +ArgumentError+ -> +formula+ must be +:split+ or +:classic+.
    def haversine(u, v, unit = :meters, formula: :split)
      # TODO: Create better exceptions.
      raise ArgumentError if u.size != 2 || v.size != 2
      raise ArgumentError if unit.class != Symbol

      c = case formula
          when :split then split_central_angle(u, v)
          when :classic then classic_central_angle(u, v)
          else raise ArgumentError, "formula must be :split or :classic, got #{formula.inspect}"
          end

      EARTH_RADIUS[unit] * c
    end

    private

    # The haversine a, which is small for nearby points, and 1 - a written
    # without subtraction. With s = sin²(Δλ/2),
    #   1 - a = cos²(Δφ/2)(1 - s) + sin²((φ1 + φ2)/2) s,
    # a sum of nonnegative terms, so it keeps full relative precision when
    # the points are nearly antipodal and it is tiny.
    def split_central_angle(u, v)
      half_dlat = (u[0] - v[0]) * RAD_PER_DEG / 2
      half_dlon = (u[1] - v[1]) * RAD_PER_DEG / 2
      half_sum_lat = (u[0] + v[0]) * RAD_PER_DEG / 2

      s = Math.sin(half_dlon)**2
      a = haversine_term(u, v, half_dlat, s)
      b = ((Math.cos(half_dlat)**2) * (Math.cos(half_dlon)**2)) + ((Math.sin(half_sum_lat)**2) * s)

      2 * Math.atan2(Math.sqrt(a), Math.sqrt(b))
    end

    def classic_central_angle(u, v)
      half_dlat = (u[0] - v[0]) * RAD_PER_DEG / 2
      half_dlon = (u[1] - v[1]) * RAD_PER_DEG / 2

      a = haversine_term(u, v, half_dlat, Math.sin(half_dlon)**2)
      # Rounding can leave a just above 1 for antipodal points. The comparison
      # is false for NaN, so NaN still propagates.
      a = 1.0 if a > 1.0
      2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    end

    # a = sin²(Δφ/2) + cos φ1 cos φ2 sin²(Δλ/2), with s = sin²(Δλ/2).
    def haversine_term(u, v, half_dlat, s)
      (Math.sin(half_dlat)**2) + (Math.cos(v[0] * RAD_PER_DEG) * Math.cos(u[0] * RAD_PER_DEG) * s)
    end
  end

  extend Measurable::Haversine
end
