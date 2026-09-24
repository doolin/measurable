# Backlog

Items not yet scheduled. Add new work here. Move to `todo.md`
when it becomes active.

<!-- Newest items at the top. -->

- **Fix Levenshtein** — Wrong results, confirmed 2026-09-23:
  kitten/sitting gives 2 (should be 3), flaw/lawn 1 (2),
  a/b 0 (1), ab/ba 1 (2), and abcd/b raises `NoMethodError`.
  In `lib/measurable/levenshtein.rb` the inner loop compares
  `u[i] == v[j]` with 1-based `i, j` (it should compare
  `u[i - 1]` and `v[j - 1]`), every row is initialized to
  `0..n` (the first column should be `0..m`), and the
  `u, v` swap runs after the matrix is sized, so indices run
  past it. The specs pass only because each case they test
  happens to give the right answer despite the off-by-one.
  Add known-answer specs (the list above) before fixing.
- **Fix `WeightedOverlap#feature_contribution`** — It reads
  `@weight`, which is never set (the attribute is
  `@weights`), so every call raises `NoMethodError`. Nothing
  in the repo calls it. Either fix it (`@weights[idx]`, and
  return the ternary) or delete it as dead public API.
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
  Fix Levenshtein first, or the golden file records its
  wrong answers.
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
- **Refresh the README** — It still names NMatrix as
  supported (lines 7–12, 63, 72), shows a dead Travis badge
  and a Code Climate badge for `agarie/measurable`, and
  claims testing on MRI 1.9.3–2.1 and Rubinius. Rewrite
  those passages to match the fork and Ruby 4, and keep the
  credit to `reddavis`. Roadmap milestone 1.
