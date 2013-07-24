require 'measurable/version'

# Distance measures. The require order is important.
require 'measurable/euclidean'
require 'measurable/cosine'
require 'measurable/jaccard'
require 'measurable/tanimoto'
require 'measurable/haversine'
require 'measurable/maxmin'

module Measurable
  # PI / 180 degrees.
  RAD_PER_DEG = Math::PI / 180

  extend self # expose all instance methods as singleton methods.
end
