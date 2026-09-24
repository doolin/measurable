# Decisions

Significant decisions — architecture, tooling, direction —
one `##` section per decision, newest first: the context, the
decision, and its consequences. No numbering; sections are
the unit.

## Open questions

<!-- Decided: "## YYYY-MM-DD — Title" sections below, newest
     first. -->

## 2026-09-24 — Haversine computes 1 − a without subtraction

**Context.** The haversine formula takes the central angle
as 2·atan2(√a, √(1 − a)). Near antipodal points a is close
to 1, so `1 - a` keeps only half the digits, and the error is
about √ε times the distance: up to 3.6×10⁷ ε, or 13 cm on
20,000 km, against a 60-digit reference. The operator asked
for the better formula, with the old one kept as an option.

**Decision.** `haversine(u, v, unit, formula: :split)`.
`:split`, the default, keeps the classic a (accurate for
nearby points) and computes its complement as
cos²(Δφ/2)·cos²(Δλ/2) + sin²((φ₁+φ₂)/2)·sin²(Δλ/2), a sum
of nonnegative terms. `:classic` is the formula at `2c4b52d`,
bit-identical to it. Any other value raises `ArgumentError`.
Writing a in the same split form was tried and rejected: its
(φ₁+φ₂)/2 argument adds a rounding that near the poles cost
16.7 ε at short range, against 6.5 ε for the product form.

**Consequences.** Maximum error against the reference: near
antipodes 1.4 ε, exact antipodes 0.5 ε, random pairs 11 ε,
pairs within 1 m 7 ε (the floor, shared by both formulas,
comes from converting latitudes to radians). Default results
move by a few ulps everywhere; callers who need the old bits
pass `formula: :classic`. The Vincenty (atan2 of cross and
dot) form was not used: it is well-conditioned near
antipodes, but by analysis (not measured here) its
numerator cancels at short range, costing relative accuracy
there.

## 2026-09-24 — Minkowski takes an order p

**Context.** `minkowski(u, v)` computed only the L1
(city-block) distance, though the Minkowski distance is the
family of Lp distances. The operator asked for the whole
family.

**Decision.** `minkowski(u, v, p = 1)`. Any real p > 0 is
accepted, and `Float::INFINITY` gives the Chebyshev
distance. For 0 < p < 1 the result is defined but is not a
metric, and the method documentation says so. A non-numeric,
NaN, zero or negative p raises `ArgumentError`. General p is
computed as m · (Σ (|dᵢ|/m)ᵖ)^(1/p), with m the largest
|dᵢ|, so it neither overflows nor underflows where the plain
sum of powers would.

**Consequences.** Existing calls, and the `cityblock` and
`manhattan` aliases, keep p = 1 through the unchanged
left-to-right sum: results are bit-identical, and Integer
inputs still give an Integer. At p = 2 the result agrees
with `euclidean` to a few ulps, and stays finite where
`euclidean`'s sum of squares overflows. At p = ∞ it equals
`chebyshev` exactly.

## 2026-09-23 — Do not publish this fork

**Context.** rubygems.org has `measurable` 0.0.1–0.0.9 and
0.0.11 (no 0.0.10; checked 2026-09-23).
`lib/measurable/version.rb` here says 0.0.10, behind that
line, and the rubygems name is presumably held by upstream.

**Decision.** This fork is not published to rubygems.org,
per the operator. Anyone who wants it consumes it from git.

**Consequences.** Never run `rake release`. The
`bundler/gem_tasks` task is still defined through the
Rakefile. The version number carries no release meaning
here, and it does not need to stay ahead of rubygems.

## 2026-09-23 — Support Ruby 4.0 and later

**Context.** The gemspec claimed `required_ruby_version >=
1.9.3`, a floor nobody has tested in a decade. The revival
was verified only on Ruby 4.0.7, which `.ruby-version` pins
for development. Supporting 3.2 through 3.4 as well was
considered. It would have meant adding each of those
versions to the CI matrix.

**Decision.** `required_ruby_version = '>= 4.0'`, chosen by
the operator.

**Consequences.** A build of this fork will not install on
Ruby 3.x. CI needs only one Ruby at first. Lowering the
floor later is easy, but each version added needs a passing
CI run. This fork is never published (see the decision
above), so the floor affects only people building from
git.

## 2026-09-23 — Declare `matrix`, drop the `pry` require

**Context.** `lib/measurable/mvdm.rb` required `matrix` and
`pry` when it loaded, both added in `55d83c8` (2016-04-09).
`matrix` has not been a default gem since Ruby 3.1, so under
Bundler on Ruby 4.0.7 loading the gem raised `LoadError`
before any spec ran. `pry` was only a development
dependency, and no file in `lib/` or `spec/` calls it, so it
was leftover debugging. It broke loading the gem in any
program without `pry` installed. The specs cannot catch
that, because `pry` is in the development bundle.

**Decision.** Declare `matrix` as a runtime dependency and
delete `require 'pry'`. Rewriting `MVDM` to avoid `Matrix`
was the alternative. It would remove a dependency, but it
means rewriting a working measure for no gain in
correctness.

**Consequences.** `bundle exec rake` passes on Ruby 4.0.7:
101 examples, 0 failures. With the development group
excluded (`BUNDLE_WITHOUT=development`), `require
"measurable"` loads and computes, while `pry` cannot be
loaded, so the gem no longer depends on it at load time.

## 2026-09-23 — Drop `nmatrix`

**Context.** `nmatrix` was the gem's only runtime dependency.
It is an unmaintained C extension, and on Ruby 4.0.7 its
build fails ("You need a version of g++ which supports
-std=c++0x or -std=c++11"), which stopped `bundle install`
entirely. The code has never used it at runtime:

- No file in `lib/` or `spec/` references it today.
- It entered the gemspec in `55d83c8` (2016-04-09, "redesign
  matrix precompute fot MVDM"), but that rewrite uses the
  standard library's `Matrix.build`, not NMatrix.
- The only time the project ever loaded it was a
  `require 'nmatrix'` in `spec_helper.rb` from `5a50f25`
  (2012-10) to `aeec935` (2013-03), and no spec ever built
  an NMatrix.
- A pickaxe search of all refs, `upstream/master`
  included, finds nothing else.

**Decision.** Remove it from the gemspec. Do not replace it
with `numo-narray`: that only makes sense if a measure is
rewritten to run vectorized, and none is planned.

**Consequences.** `bundle install` succeeds on Ruby 4.0.7.
Most measures are duck-typed over enumerables, so a caller
who installs NMatrix separately may still pass one in; the
gem just no longer installs it. The README still names
NMatrix, and that belongs to the README refresh in
`backlog.md`.
