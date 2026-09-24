module Measurable
  module Levenshtein
    # call-seq:
    #     levenshtein(u, v) -> Integer
    #
    # Give the edit distance between two binary sequences +u+ and +v+ where each
    # edit (insertion, deletion, substitution) required to change on into the
    # other increments the total distance.
    #
    # For example:
    #   levenshtein('kitten', 'sitting') == 3
    #
    # Because
    # 1. kitten -> sitten (substitution "s" for "k")
    # 2. sitten -> sittin (substitution "i" for "e")
    # 3. sittin -> sitting (insertion of "g" at the end)
    #
    # See: http://en.wikipedia.org/wiki/Levenshtein_distance
    #
    # Arguments:
    # - +u+ -> Array or String.
    # - +v+ -> Array or String.
    # Returns:
    # - Integer value representing the Levenshtein distance between +u+ and +v+.
    #
    def levenshtein(u, v)
      return 0 if u == v
      return u.size if v.size == 0
      return v.size if u.size == 0

      # Keep only two rows of the dynamic-programming table, each as long as
      # the shorter sequence plus one. previous[i] is the distance between
      # the first i elements of u and the first j - 1 elements of v.
      u, v = v, u if v.size < u.size
      previous = (0..u.size).to_a

      (1..v.size).each do |j|
        current = [j]
        (1..u.size).each do |i|
          cost = u[i - 1] == v[j - 1] ? 0 : 1
          current << [
            previous[i] + 1,        # deletion
            current[i - 1] + 1,     # insertion
            previous[i - 1] + cost  # substitution, or a match
          ].min
        end
        previous = current
      end

      previous[u.size]
    end
  end

  extend Measurable::Levenshtein
end
