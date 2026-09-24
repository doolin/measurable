# Decisions

Significant decisions — architecture, tooling, direction —
one `##` section per decision, newest first: the context, the
decision, and its consequences. No numbering; sections are
the unit.

## Open questions

### Where `mvdm.rb` gets `matrix` and `pry`

`lib/measurable/mvdm.rb` requires `matrix` and `pry` when it
loads. `pry` is only a development dependency, so requiring
`measurable` in a program without `pry` raises `LoadError`.
That looks like leftover debugging. `matrix` has not been a
default gem since Ruby 3.1, so under Bundler it has to be
declared as a runtime dependency. The alternative is to
rewrite `MVDM` to use plain arrays or hashes.

Leading option: delete `require 'pry'` and add `matrix` as a
runtime dependency.

<!-- Decided: "## YYYY-MM-DD — Title" sections below, newest
     first. -->

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
