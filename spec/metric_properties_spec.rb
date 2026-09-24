require 'prop_check'

# Property-based checks of the metric axioms for the measures that are
# metrics on R^n. prop_check generates the inputs and, on failure, shrinks
# them to a small counterexample. Its runs are not seeded: each run draws
# fresh inputs, and a failure reports the counterexample to reproduce.
#
# `real_float` gives finite floats of moderate magnitude. Special values
# (NaN, infinities, subnormals) are left out on purpose until the NaN
# policy is decided; see .development/backlog.md.
# Cross-cutting: it checks several measures, not one class.
describe 'Metric axioms' do # rubocop:disable RSpec/DescribeClass
  # Three vectors of one common length, 1 to 8.
  let(:triples) do
    g = PropCheck::Generators
    g.choose(1..8).bind do |n|
      vector = g.array(g.real_float, min: n, max: n)
      g.tuple(vector, vector, vector)
    end
  end

  metrics = {
    'euclidean' => ->(u, v) { Measurable.euclidean(u, v) },
    'chebyshev' => ->(u, v) { Measurable.chebyshev(u, v) },
    'minkowski, p = 1' => ->(u, v) { Measurable.minkowski(u, v) },
    'minkowski, p = 2' => ->(u, v) { Measurable.minkowski(u, v, 2) },
    'minkowski, p = 3' => ->(u, v) { Measurable.minkowski(u, v, 3) },
    'minkowski, p = infinity' => ->(u, v) { Measurable.minkowski(u, v, Float::INFINITY) }
  }

  metrics.each do |name, d|
    context "with #{name}" do
      it 'is zero exactly from a vector to itself' do
        PropCheck.forall(triples) do |(u, _, _)|
          expect(d.call(u, u)).to eq 0
        end
      end

      it 'is positive between different vectors' do
        PropCheck.forall(triples) do |(u, v, _)|
          expect(d.call(u, v)).to be > 0 if u != v
        end
      end

      it 'is exactly symmetric' do
        PropCheck.forall(triples) do |(u, v, _)|
          expect(d.call(u, v)).to eq d.call(v, u)
        end
      end

      it 'satisfies the triangle inequality, up to rounding' do
        PropCheck.forall(triples) do |(u, v, w)|
          bound = d.call(u, v) + d.call(v, w)
          expect(d.call(u, w)).to be <= bound * (1 + (8 * Float::EPSILON))
        end
      end
    end
  end
end
