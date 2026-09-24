# Decisions

Significant decisions — architecture, tooling, direction —
one `##` section per decision, newest first: the context, the
decision, and its consequences. No numbering; sections are
the unit.

## Open questions

<!-- Decided: "## YYYY-MM-DD — Title" sections below, newest
     first. -->

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
