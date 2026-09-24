# Changelog

Shipped work worth recording — a defect ledger, then one
dated line per item, newest first. When an item leaves `todo.md` finished, note it
here. Not every completion needs an entry; record the ones a
future reader would want to find.

## Defect ledger

Every defect fixed, numbered in the order fixed, with its
commit. Keep the count current: add an entry in the same
commit as the fix. A defect is behavior that was wrong
before the fix — not modernization, style, or cleanup.

**Count: 14** — code 8, tests 2, dependencies and build 4.

### In the gem's code

| # | Defect | Commit |
|---|---|---|
| 1 | `mvdm.rb` required `pry` at load; loading the gem without `pry` raised `LoadError` | `4cdf070` |
| 2 | `mvdm.rb` required `matrix` without declaring it; `LoadError` under Bundler on Ruby ≥ 3.1 | `4cdf070` |
| 3 | Levenshtein returned wrong distances (kitten/sitting → 2) and crashed on some pairs | `d6ce1c0` |
| 4 | `WeightedOverlap#feature_contribution` read never-set `@weight`; always `NoMethodError` | `54dbd58` |
| 5 | `MeasurableObject#distance` `throw`ed a string instead of raising | `d3f8f26` |
| 6 | Haversine `:feet` used 5282 ft per mile | `3aa72f5` |
| 7 | Haversine mile radius inconsistent with km radius (~0.07%) | `3aa72f5` |
| 14 | Cosine similarity rounded past 1 (26% of random `v` against itself), giving negative distances; nearly parallel distances cancelled to 0; huge or tiny components gave NaN | this commit |

### In the specs

| # | Defect | Commit |
|---|---|---|
| 8 | MVDM Marshal spec discarded the restored metric; checked only that nothing raised | `062b775` |
| 9 | Overlap-distance spec passed by accident (read Integer bits) | `d3f8f26` |

### In dependencies and build

| # | Defect | Commit |
|---|---|---|
| 10 | Unused `nmatrix` runtime dependency; C extension fails to build, `bundle install` failed | `927b775` |
| 11 | `rake ~> 10.1` cannot start on Ruby 4.0 (`ostruct` no longer a default gem) | `94f0236` |
| 12 | `rdoc ~> 4.1` pinned 4.3.0, with CVE-2021-31799 (High) and CVE-2024-27281 (Medium) | `ae7989e` |
| 13 | Rakefile named the `fivefish` RDoc generator, which nothing provides | `ae7989e` |

## Log

- 2026-09-24 — Cosine similarity and distance rebuilt on
  unit vectors from a scaled norm: similarity clamped to
  [−1, 1], distance as ‖â − b̂‖²/2 without cancellation.

- 2026-09-24 — `minkowski(u, v, p = 1)`: the full Lp family,
  p > 0 through infinity, scaled against overflow and
  underflow. Default results unchanged.

- 2026-09-24 — Haversine units derived from one radius:
  miles = km / 1.609344, feet = miles × 5280 (was 5282).
  `:km` and `:meters` results unchanged; `:miles` rise about
  0.07%, `:feet` about 0.03%.

- 2026-09-24 — `MeasurableObject#distance` raises
  `ArgumentError` when no measure is set, instead of
  `throw`ing a string; its overlap-distance spec no longer
  passes by accident.

- 2026-09-24 — Fixed `WeightedOverlap#feature_contribution`
  (read the never-set `@weight`); `distance` now sums it, so
  the per-feature rule lives in one place.

- 2026-09-24 — Fixed Levenshtein, which returned wrong
  distances (kitten/sitting gave 2) and crashed on some
  pairs. Two-row dynamic program; known-answer and
  metric-property specs; 6,000 random comparisons agree
  with the recursive definition.

- 2026-09-24 — First GitHub Actions run green (bundler-audit,
  specs, RuboCop on Ruby 4.0.7). Roadmap milestone 2 landed.

- 2026-09-23 — README brought up to date: this fork's CI
  badge, install-from-git, Ruby 4.0+, the fork lineage, no
  NMatrix claims, and a known-issue note on Levenshtein.
  Roadmap milestone 1 (revival on Ruby 4.0.7) landed.

- 2026-09-23 — RuboCop brought forward to 1.91 with the
  performance and rspec plugins: config regenerated, safe
  corrections applied (765 → 430 offenses) with outputs
  verified bit-identical, and a RuboCop step added to CI.

- 2026-09-23 — Gemspec metadata points at this fork: authors
  (Agarie, generall, Doolin), email, homepage, a description
  distinct from the summary; dropped `gem.date`. `gem build`
  is warning-free.

- 2026-09-23 — Replaced `.travis.yml` with a GitHub Actions
  workflow: bundler-audit, then `bundle exec rake`, on the
  Ruby in `.ruby-version`.

- 2026-09-23 — Moved the `rdoc` pin from `~> 4.1` to `~> 8.0`,
  clearing CVE-2021-31799 and CVE-2024-27281, and dropped the
  unprovided `fivefish` generator; `rake rdoc` builds again.

- 2026-09-23 — Raised `required_ruby_version` from
  `>= 1.9.3` to `>= 4.0`.

- 2026-09-23 — Pinned the development Ruby to 4.0.7 with
  `.ruby-version`.

- 2026-09-23 — Dropped the `pry` development dependency;
  nothing in the repo used it.

- 2026-09-23 — Declared `matrix` and removed the stray
  `require 'pry'` from `mvdm.rb`; `bundle exec rake` passes
  on Ruby 4.0.7 (101 examples, 0 failures).

- 2026-09-23 — Moved the `rake` pin from `~> 10.1` to
  `~> 13.0`; `bundle exec rake` starts on Ruby 4.0.7.

- 2026-09-23 — Dropped the unused `nmatrix` runtime
  dependency; `bundle install` now succeeds on Ruby 4.0.7.

- 2026-09-23 — Ruby 4.0.7 baseline taken: three ordered
  failures (nmatrix build, rake/ostruct, matrix load)
  recorded in `backlog.md`; specs pass (101/0) past them.
