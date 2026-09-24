# Backlog

Items not yet scheduled. Add new work here. Move to `todo.md`
when it becomes active.

<!-- Newest items at the top. -->

- **`interfaces.rb` throws a string** — `MeasurableObject#distance`
  does `throw 'No measure specified'`, which raises
  `UncaughtThrowError`, not a meaningful error. Should be
  `raise ArgumentError, ...`, with a spec.
- **Haversine unit constants** — `feet:` is
  `EARTH_RADIUS_IN_MILES * 5282`; a mile is 5280 feet. The
  mile radius (3956) and km radius (6371 km ≈ 3958.8 mi)
  also disagree, so `:miles` and `:km` results differ by
  about 0.07%. Derive every unit from one radius.
- **Golden-output regression test** — The RuboCop cleanup
  was verified by a differential script: seeded inputs to
  every measure, results printed in Float#inspect form,
  byte-compared between two `lib/` trees. Most specs use
  `be_within`, so they cannot catch a last-bit change. Bring
  that script into the repo (a spec that compares against a
  checked-in golden file, or a `script/` tool), so any
  future refactor of the numerical code gets the same check.
- **Clear the rest of `.rubocop_todo.yml`** — 430 offenses
  remain after the 2026-09-23 pass, none autocorrected on
  purpose:
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
