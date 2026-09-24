# Changelog

Shipped work worth recording — one dated line per item,
newest first. When an item leaves `todo.md` finished, note it
here. Not every completion needs an entry; record the ones a
future reader would want to find.

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
