# Lessons learned

Traps and techniques from doing the work — the things
that were only obvious in hindsight, and the methods
worth reusing. One `##` section per theme, concrete
enough to lift: playbooks and skills harvest this file.

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
