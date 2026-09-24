# Lessons learned

Traps and techniques from doing the work — the things
that were only obvious in hindsight, and the methods
worth reusing. One `##` section per theme, concrete
enough to lift: playbooks and skills harvest this file.

Write each entry as a principle with its evidence, not as a
procedure. The tools will change. The reason a check exists,
and the trap it guards against, stay true.

## A test is evidence only if it can fail

- **Show the new test failing on the old code.** A spec
  written after a fix proves nothing until it has been seen
  to fail on the pre-fix code. Check this every time. It
  caught a spec below that would have passed either way.
- **Match exactly when a subclass could stand in.**
  `raise_error(ArgumentError, /msg/)` accepted the old
  `throw`, because `UncaughtThrowError` subclasses
  `ArgumentError` and its message contains the text. Loose
  matchers pass for the wrong reason. Say the exact class
  and the exact message.
- **Choose inputs where the wrong answer differs.** The old
  overlap-distance spec passed because its inputs gave the
  expected number through a completely different
  computation (Integer bit reads). If a plausible bug gives
  the same answer on an input, that input tests nothing.
- **An oracle should share nothing with the code but the
  definition.** The Levenshtein cross-check uses the
  recursive textbook recurrence, not a second copy of the
  two-row loop. A shared structure would share the bug.

## Checking that numerical code didn't change

- **Tolerances hide changes; compare bits.** Most specs
  here use `be_within`, so a refactor that moves a result by
  one ulp passes. When a change is supposed to preserve
  behavior, run the same seeded inputs through the old and
  new code. Record results in a form that round-trips
  exactly (`Float#inspect`), and require byte-identical
  output. When a change is supposed to alter behavior, the
  same comparison should differ exactly where intended (for
  Haversine, the `:miles` and `:feet` lines and nothing
  else).
- **Count the errors, not only the matches.** An input that
  raises exercises nothing, and "error equals error" looks
  like agreement. Tally results by measure and outcome. That
  tally is what exposed the Levenshtein crash.
- **Summation order is part of the answer.** `Array#sum`
  compensates, `reduce(:+)` does not, and they can differ in
  the last bit. A spec that recomputes a sum to compare
  exactly must add in the same order as the code under test.
- **Automated "safe" rewrites still need reading.** RuboCop's
  safe corrections preserved every result here, but mangled
  prose ("onlies work", "calcs") and layout. The unsafe and
  judgment cops can change numbers: `Performance/Sum`
  changes the summation algorithm, and an unused assignment
  in numerical code can be a dropped value. Review those by
  hand.

## Probing a measure at its extremes

Every measure has an input region where the naive formula
fails: overflow and underflow of intermediate sums,
cancellation near a limit, `0 × log 0`, rounding that pushes
an argument outside a function's domain. Probe each against
an independent reference (a scaled norm, a cancellation-free
rearrangement, a closed form), and count failures over many
random inputs rather than trying one. The 2026-09-24 probes
found `cosine_similarity(v, v) > 1` in 26% of random
vectors, and Haversine raising `Math::DomainError` on 3.95%
of antipodal pairs. A handful of hand-picked cases would
have missed both.

## `gh` in a fork with an `upstream` remote

With no default repository set, `gh` resolves to the
`upstream` remote ahead of `origin`. In a fork, bare
`gh run list`, and anything built on it such as `watch-ci`,
queries the upstream repo. It reports "no run found" while
the fork's run is green. Set the default repository once per
clone (`gh repo set-default <fork>`). It lives in
`.git/config`, so a fresh clone needs it again.

## Reviving a long-dormant gem

- **Confirm which Ruby is actually running.** Version
  managers select a Ruby through shell hooks that an agent's
  non-interactive shell may never run. On this machine the
  default was 4.0.1 while `.ruby-version` says 4.0.7. Check
  `ruby -v` in the same context as the command, or select
  the version explicitly, before trusting any result.
- **Resolve the way a fresh clone would.** A gem's lockfile
  is git-ignored, so the one on disk records one machine's
  past, not the project. Set it aside, don't delete it: it
  is untracked and can't be recovered.
- **Find the whole list of failures, not only the first.** A
  failure that stops the run hides everything after it. Make
  the smallest temporary change to get past each one, record
  it, and revert everything before committing. The result is
  an ordered work queue.
- **Installing is not running.** `rake ~> 10.1` installed
  cleanly and failed only when run, on Ruby 4.0's removal of
  `ostruct` as a default gem. Run the tasks, not just the
  install.
