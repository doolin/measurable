# Backlog

Items not yet scheduled. Add new work here. Move to `todo.md`
when it becomes active.

<!-- Newest items at the top. -->

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
