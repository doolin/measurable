# Decisions

Significant decisions — architecture, tooling, direction —
one `##` section per decision, newest first: the context, the
decision, and its consequences. No numbering; sections are
the unit.

## Open questions

### What to do about `nmatrix`

The gemspec declares `nmatrix` as the only runtime
dependency. `nmatrix` is an unmaintained C extension and is
unlikely to build on Ruby 4.0.7. As of 2026-09-23 no file in
`lib/` or `spec/` requires or references it. It appears only
in the gemspec and in the README, which says measures accept
any enumerable, NMatrix included.

Options:

- **Drop it (leading option).** The code never loads it, so
  removing it from the gemspec loses nothing. The README
  should keep saying that any enumerable works, without
  naming NMatrix.
- **Replace it with `numo-narray`.** This only makes sense
  if a measure is rewritten to run vectorized, and none is
  planned.

Confirm first that a spec passing an NMatrix does not exist
in history or upstream, then decide.

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
