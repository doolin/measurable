# Backlog

Items not yet scheduled. Add new work here. Move to `todo.md`
when it becomes active.

<!-- Newest items at the top. -->

- **Replace Travis with GitHub Actions** — `.travis.yml` is
  dead. Add a workflow that runs `bundle exec rake` on the
  Ruby versions the gemspec claims to support. Roadmap
  milestone 2.
- **Fix `mvdm.rb` load-time requires** — Remove the stray
  `require 'pry'` and declare `matrix`. See the open question
  in `adr.md`. Roadmap milestone 1.
- **Modernize the gemspec** — Remove the `rake ~> 10.1` and
  `rdoc ~> 4.1` pins, and raise `required_ruby_version` from
  `>= 1.9.3`. Point authors, email and homepage at the fork
  chain in `AGENTS.md` instead of `agarie/measurable`.
  Remove `gem.date`, which Bundler no longer uses.
  Roadmap milestone 1.
- **Resolve `nmatrix`** — Probably remove it from the
  gemspec, since the code never loads it. See the open
  question in `adr.md`. Roadmap milestone 1.
- **First install on Ruby 4.0.7** — Run `bundle install` and
  `bundle exec rake` as things stand. Record each failure;
  that list is the revival's work queue. Roadmap
  milestone 1.
