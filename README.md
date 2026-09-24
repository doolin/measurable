# Measurable

[![CI](https://github.com/doolin/measurable/actions/workflows/ci.yml/badge.svg)](https://github.com/doolin/measurable/actions/workflows/ci.yml)

A gem to test what metric is best for certain kinds of datasets in machine
learning. The measures work on `Array`s and, for most of them, on any
enumerable.

This repository is a fork of [agarie/measurable](https://github.com/agarie/measurable)
by way of [generall/measurable](https://github.com/generall/measurable), which
itself began as a fork of [Distance Measure](https://github.com/reddavis/Distance-Measures).
Thank you, [@reddavis][reddavis]. :)

## Installation

This fork is not published to rubygems.org (the `measurable` gem there is the
upstream line). Use it from git:

```ruby
# Gemfile
gem 'measurable', github: 'doolin/measurable'
```

It requires Ruby 4.0 or later, and CI runs it on the Ruby named in
`.ruby-version`.

## Available distance measures

I'm using the term "distance measure" without much concern for the strict
mathematical definition of a metric. If the documentation for one of the
methods isn't clear about it being or not a metric, please open an issue.

The following are the similarity measures supported at the moment:

- Euclidean distance
- Squared euclidean distance
- Cosine distance
- Max-min distance (from ["K-Means clustering using max-min distance measure"][maxmin])
- Jaccard distance
- Tanimoto distance
- Haversine distance
- Minkowski (aka Cityblock or Manhattan) distance
- Chebyshev distance
- Hamming distance
- [Levenshtein distance](http://en.wikipedia.org/wiki/Levenshtein_distance)
- [Kullback-Leibler divergence](http://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence)
- Modified Value Difference Metric (MVDM)
- Weighted overlap with Information Gain and Information Gain Ratio

**Known issue:** Levenshtein currently returns wrong distances for many
inputs (kitten/sitting gives 2, not 3) and raises on some. A fix is pending.

## How to use

The API I intend to support is something like this:

```ruby
require 'measurable'

# Calculate the distance between two points in space.
Measurable.euclidean([1, 1], [0, 0]) # => 1.41421

# Calculate the norm of a vector, i.e. its distance from the origin.
Measurable.euclidean([1, 1]) # => 1.4142135623730951

# Get the cosine distance between
Measurable.cosine_distance([1, 2], [2, 3]) # => 0.007722123286332261

# Calculate sum of squares directly.
Measurable.euclidean_squared([3, 4]) # => 25
```

Most of the methods accept arbitrary enumerable objects instead of Arrays.

You can use `Measurable::MeasurableObject` mixin to make your own object measurable.
You can also use distance function like object. For example, you can pass distance function to some classification algorithm.

```ruby
class String
	# including mixin
	include Measurable::MeasurableObject
	# This function returns measurable object (Array, Enumerable, etc.)
	def coordinates
		self
	end
end
# Strings are measurable now!
s1 = 'string1'
s2 = 'string2'
# Setting up measure to use
s1.measure = Measurable.object_for(:hamming)
s1.distance s2
# => 1
```

## Documentation

The methods carry RDoc comments. Build the HTML locally with
`bundle exec rake rdoc`; it lands in `html/`.

## License

See LICENSE for details.

The original `distance_measures` gem is copyrighted by [@reddavis][reddavis].

[maxmin]: http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=05156398
[reddavis]: https://github.com/reddavis
