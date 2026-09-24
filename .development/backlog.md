# Backlog

Items not yet scheduled. Add new work here. Move to `todo.md`
when it becomes active.

<!-- Newest items at the top. -->

- **Replace Travis with GitHub Actions** — `.travis.yml` is
  dead. Add a workflow that runs `bundle exec rake` on the
  Ruby versions the gemspec claims to support. Roadmap
  milestone 2.
- **Gemspec metadata** — Raise `required_ruby_version` from
  `>= 1.9.3`. Point authors, email and homepage at the fork
  chain in `AGENTS.md` instead of `agarie/measurable`.
  Remove `gem.date`, which Bundler no longer uses. Not a
  blocker: the 2026-09-23 baseline installs without it.
  Roadmap milestone 1.

### Ruby 4.0.7 baseline failures (2026-09-23)

Found by a fresh resolve (no lockfile) with
`rvm 4.0.7 do bundle install`, then `bundle exec rake` and
`bundle exec rspec`. Each failure was worked around
temporarily to see the next one, and every workaround was
reverted. Listed in the order they fail. Fix them in this
order, one commit each.

- **1. `nmatrix` does not build** — `nmatrix 0.2.4`
  extconf fails: "You need a version of g++ which supports
  -std=c++0x or -std=c++11". This stops `bundle install`
  entirely. The code never loads it (see `adr.md`), so
  remove the dependency. Roadmap milestone 1.
- **2. `rake ~> 10.1` cannot start** — `bundle install`
  succeeds with `rake 10.5.0`, but `bundle exec rake` raises
  `LoadError: cannot load such file -- ostruct`, because
  Ruby 4.0 no longer ships `ostruct` as a default gem.
  Loosen the pin to current rake. `rdoc ~> 4.1` installs
  (4.3.0), but whether `require 'rdoc/task'` in the Rakefile
  works on Ruby 4 is untested, because rake fails first.
  Check it once rake runs. Roadmap milestone 1.
- **3. `mvdm.rb` cannot load `matrix`** — `bundle exec rspec`
  fails loading `spec_helper`: `cannot load such file --
  matrix` at `lib/measurable/mvdm.rb:48`. Declare `matrix`
  as a runtime dependency. In the same commit, remove
  `require 'pry'` at line 49. The specs don't catch that
  one, because `pry` is in the development bundle, but
  outside the development bundle, where `pry` is not
  installed, loading the gem raises `LoadError`. See
  `adr.md`. Roadmap milestone 1.
- **After 1–3: specs green** — With `nmatrix` removed and
  `matrix` added, `bundle exec rspec` ran 101 examples with 0
  failures and no warnings. No failures are known past
  these three.
