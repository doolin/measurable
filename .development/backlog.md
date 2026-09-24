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

- **Adopt property and mutation testing** — The research is
  done: `.development/plans/testing-research.md` recommends
  `prop_check` (its `float` generator produces NaN,
  ±Infinity, Float::MAX and subnormals; CI stops at Ruby
  3.4) and `mutant` under `--usage opensource`
  (proprietary EULA, free for public open-source repos,
  Ruby 4.0 supported). Before adopting, decide:
  - whether mutant's EULA is acceptable, and whether its
    "Free Project License" needs a sign-up;
  - which properties each measure owes: metric axioms where
    they hold, bounds (cosine in [−1, 1], Jaccard in [0, 1],
    KL ≥ 0), invariances, and closed forms. Which
    "distances" here are not metrics (Tanimoto,
    `euclidean_squared`, `minkowski` with p < 1), and should
    the specs say so?
  - whether to take a mutation-score baseline first, to see
    where the `be_within` specs are weakest.
  This relates to the golden-output item below: both guard
  numerical behavior, and they may become one harness.

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
