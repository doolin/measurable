# Todo

Work in progress. Keep this short — if it grows beyond a
handful of items, move deferred work back to `backlog.md`.

## Active

<!-- Items currently being worked on. -->

- **Property testing with `prop_check`** — Chosen in
  `.development/plans/testing-research.md` for its `float`
  generator (NaN, ±Infinity, Float::MAX, subnormals) and its
  shrinking. Its own CI stops at Ruby 3.4.
  - [x] Add it as a development dependency; confirm it runs
        on Ruby 4.0.7 under RSpec
  - [x] First property specs, on finite floats, for a
        measure whose properties are settled: the metric
        axioms for Euclidean, Chebyshev and Minkowski at
        p = 1, 2, 3, ∞ (`spec/metric_properties_spec.rb`)
  - [ ] Decide which properties each measure owes, and
        which "distances" are not metrics (Tanimoto,
        `euclidean_squared`, `minkowski` with p < 1)
  - [ ] Special-value runs (NaN, ±Infinity, subnormals, and
        a hand-added -0.0). These wait on the NaN-policy
        decision in `backlog.md`.

## Blocked

<!-- Items waiting on something. Note what they're waiting on. -->
