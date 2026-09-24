# Changelog

Shipped work worth recording — one dated line per item,
newest first. When an item leaves `todo.md` finished, note it
here. Not every completion needs an entry; record the ones a
future reader would want to find.

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
