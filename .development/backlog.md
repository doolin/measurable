# Backlog

Items not yet scheduled. Add new work here. Move to `todo.md`
when it becomes active.

<!-- Newest items at the top. -->

### Stress-probe findings (2026-09-24)

Each measure was run at its numerical extremes against an
independent reference (a scaled norm, a cancellation-free
rearrangement, a closed form), with failures counted over
thousands of random inputs. Take these one at a time: a spec
that fails first, then the fix, then a ledger entry.

**Defects** (wrong results or crashes on valid input):

- **Haversine raises near antipodes** — `Math::DomainError`
  on 395 of 10,000 exactly antipodal pairs (3.95%), e.g.
  `[37.865216427464006, 35.83562198419082]` vs its antipode.
  Rounding pushes `a` above 1 and `Math.sqrt(1 - a)` fails.
  Clamp `a` to [0, 1] (or use `2 * asin(sqrt(a))` with a
  clamp). Small separations are already accurate to about
  1e-16 relative.
- **Euclidean overflows and underflows** — the sum of
  squares overflows for magnitudes around 1e154 and above
  (`euclidean([1e200, 1e200])` is Infinity, true value
  1.41e200) and underflows below about 1e-162
  (`euclidean([3e-200, 4e-200])` is 0.0, true 5e-200;
  subnormal squares give 0.6% error). Scale by the largest
  |dᵢ| as `minkowski(u, v, 2)` now does. `euclidean_squared`
  is different: its true value can itself be outside the
  Float range, so overflow there is correct.
- **KL is NaN when pᵢ = 0** — `0 * log(0 / q)` evaluates to
  `0 * -Infinity = NaN`, but by the standard convention that
  term is 0. `kullback_leibler([0, 0.5, 0.5], [0.5, 0.25, 0.25])`
  returns NaN; the true value is log 2. (qᵢ = 0 with pᵢ > 0
  correctly gives Infinity.)

**Needs a decision first** (what the right behavior is):

- **NaN policy** — `chebyshev` with a NaN raises
  `ArgumentError` ("comparison of Float with Float failed")
  from `max`, while `euclidean` returns NaN and
  `euclidean([Inf], [Inf])` returns NaN. Decide once for
  every measure: propagate NaN, or raise.
- **Jaccard's meaning** — the docs say "two binary vectors",
  but the code uses Array `&` and `|`, sets of *values*:
  `jaccard_index([1,0,0], [0,0,1])` is 1.0, where the
  positional binary reading is 0.0. `tanimoto` inherits it
  (−log₂ 1 = −0.0). Empty inputs give NaN, and disjoint sets
  give a Tanimoto of Infinity. Decide: set semantics with
  corrected docs, a positional binary-vector variant, or
  both.
- **Maxmin's domain** — documented as a similarity from the
  Visalakshi–Suguna paper. It returns −1.0 for
  `[-1, 2]` vs `[1, -2]` and NaN for two zero vectors. Decide
  whether negative inputs are out of domain (raise) and what
  all-zero input returns.
- **Levenshtein cost** — O(mn) time: 0.78 s at n = 2000 in
  pure Ruby. Probably fine; note it in the docs, or look at
  a banded or bit-parallel algorithm if long sequences
  matter.

- **Research property, mutation, and stress testing for the
  measures** — Operator request, 2026-09-24: take up after
  the current round of fixes. Research first, then propose
  a plan. Check the operator's reference corpus before
  searching the web (`~/.claude/playbooks/reference-acquisition.md`).
  The questions to answer:
  - *Property testing.* Which Ruby libraries are maintained
    and work on Ruby 4.0 with RSpec? Which properties does
    each measure owe: metric axioms where they hold
    (identity, symmetry, triangle inequality), bounds (cosine
    in [-1, 1], Jaccard in [0, 1], KL ≥ 0), invariances (e.g.
    Euclidean under translation), and known closed forms?
    Which "distances" here are *not* metrics, and should the
    specs say so? The Levenshtein specs added 2026-09-24 are
    a hand-rolled first example.
  - *Mutation testing.* Is `mutant` usable here (licensing
    for this repo, Ruby 4.0 support, RSpec integration)?
    What does a mutation score say about the current specs?
    Most use `be_within`, and the overlap-distance spec
    passed by accident until 2026-09-24, both signs that
    surviving mutants are likely.
  - *Stress and numerical robustness.* Behavior at extremes:
    overflow and underflow in sums of squares (Euclidean,
    cosine; compare a `hypot`-style scaled norm), cancellation
    in cosine for nearly parallel vectors, KL with zero
    probabilities, Haversine near antipodes and for tiny
    separations, NaN/Infinity/subnormal inputs, empty and
    very long vectors, and Levenshtein's O(mn) time on long
    sequences. What should each measure do there: raise,
    return NaN, or be exact?
  - How this relates to the golden-output regression item
    below: both guard numerical behavior, and they may
    become one harness.

- **Golden-output regression test** — The RuboCop cleanup
  was verified by a differential script: seeded inputs to
  every measure, results printed in Float#inspect form,
  byte-compared between two `lib/` trees. Most specs use
  `be_within`, so they cannot catch a last-bit change. Bring
  that script into the repo (a spec that compares against a
  checked-in golden file, or a `script/` tool), so any
  future refactor of the numerical code gets the same check.
- **Clear the rest of `.rubocop_todo.yml`** — 443 offenses
  remain as of 2026-09-24 (430 after the 2026-09-23 pass;
  the bug-fix specs added some, mostly `RSpec/InstanceVariable`
  and `RSpec/ExampleLength` in files already built on
  `before :all`), none autocorrected on purpose:
  - `RSpec/InstanceVariable` (230), `RSpec/BeforeAfterAll`,
    `RSpec/MultipleExpectations`: restructure specs to `let`
    and one behavior per example.
  - `Performance/Sum`: `Array#sum` uses Kahan–Babuska
    compensated summation for floats, so switching from
    `reduce(:+)` changes results in the last bits. That is a
    numerical decision (probably a good one), not a style fix.
  - `Style/FrozenStringLiteralComment`,
    `Style/ZeroLengthPredicate`, `Style/NumericPredicate`:
    unsafe corrections that can break duck typing on
    arbitrary enumerables. Check each against the
    differential script.
  - `Naming/MethodParameterName` (`u`, `v`, `p`, `q`): this
    is mathematical notation. Probably allow those names in
    `.rubocop.yml` rather than rename them.
  - `Style/Documentation`, `Metrics/*`: case by case.
