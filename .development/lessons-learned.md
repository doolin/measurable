# Lessons learned

Traps and techniques from doing the work — the things
that were only obvious in hindsight, and the methods
worth reusing. One `##` section per theme, concrete
enough to lift: playbooks and skills harvest this file.

## `gh` in a fork with an `upstream` remote

With no default repository set, `gh` picks among the
remotes in a fixed order: `upstream`, then `github`, then
`origin`. In a fork that keeps an `upstream` remote, bare
`gh run list` and `watch-ci` query the upstream repo, find
no runs, and `watch-ci` exits 11 ("no run found") while the
fork's run is green. Run `gh repo set-default <fork>` once
per clone. It lives in `.git/config`, so a fresh clone needs
it again.

## Refactoring numerical code without changing a bit

- **Passing specs don't show that no numbers changed.** Most
  specs here check values with `be_within`, so a refactor
  that moves a result by one ulp still passes. Run a
  differential check instead: seeded random inputs to every
  public measure, each result printed with `Float#inspect`
  (the shortest form that round-trips exactly), run against
  the old and new `lib/` (`git archive HEAD lib` into a
  scratch directory, `ruby -I<dir>`), then compare the two
  output files byte for byte. Any byte of difference is a
  change in behavior.
- **Tally the error lines, not just the diff.** An input
  that raises exercises nothing. Count results by measure
  and error class, or a check that "matches" is only
  matching `ArgumentError` to `ArgumentError`. That count
  is what surfaced the Levenshtein crash.
- **Read what "safe" autocorrect wrote.** RuboCop's safe
  cops preserved every result, but they also turned
  "should only work" into "onlies work" and "should calc"
  into "calcs", and rewrote a nested ternary as an
  unindented `if` block. Run the whitespace-only `Layout`
  cops after the others, then read the diff.
- **Keep unsafe and judgment cops out of bulk runs.**
  `Performance/Sum` swaps `reduce(:+)` for `Array#sum`,
  which uses compensated summation, so results change. In
  numerical code, `Lint/UselessAssignment` can mean a value
  that was computed and then dropped. Review both by hand.

## Taking a baseline of a long-dormant gem

- **Select the Ruby explicitly.** The rvm default on this
  machine is 4.0.1. An agent's shell never runs rvm's `cd`
  hook, so it keeps that default even though the repo now
  has a `.ruby-version` (4.0.7, added 2026-09-23). Run each
  command as `rvm 4.0.7 do <command>`. Otherwise the results
  are for the wrong Ruby. An interactive shell that `cd`s in
  does pick up 4.0.7.
- **Set the stale lockfile aside first.** A gem's
  `Gemfile.lock` is git-ignored, so the one on disk belongs
  to this machine, not the project. Resolving against it
  tests an old laptop state rather than what a fresh clone
  gets. Move it aside instead of deleting it: it is
  untracked, so a deleted copy cannot be recovered.
- **Work past each failure temporarily to find the next.** A
  failure that stops the run hides everything behind it.
  Make the smallest temporary edit that gets past it, record
  the failure, run again, and revert all the edits (`git
  checkout` the file) before committing anything. The
  result is the full ordered list of failures, not just the
  first one.
- **An install can pass while a runtime check fails.** `rake
  ~> 10.1` installed without complaint; it failed only when
  `bundle exec rake` ran, on Ruby 4.0's removal of
  `ostruct`. A successful `bundle install` says nothing
  about whether the code runs. Run the tasks too.
