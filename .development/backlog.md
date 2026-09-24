# Backlog

Items not yet scheduled. Add new work here. Move to `todo.md`
when it becomes active.

<!-- Newest items at the top. -->

- **Refresh the README** — It still names NMatrix as
  supported (lines 7–12, 63, 72), shows a dead Travis badge
  and a Code Climate badge for `agarie/measurable`, and
  claims testing on MRI 1.9.3–2.1 and Rubinius. Rewrite
  those passages to match the fork and Ruby 4, and keep the
  credit to `reddavis`. Roadmap milestone 1.

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
- **The `rdoc` pin and the Rakefile's RDoc task** — `rdoc ~>
  4.1` (4.3.0) loads fine on Ruby 4.0.7: `rake -T` lists the
  rdoc tasks without warnings. But current rdoc is 8.0.0,
  and the Rakefile sets `rdoc.generator = "fivefish"`, a
  generator that no dependency provides, so `rake rdoc`
  probably fails. Decide whether to keep an RDoc task at
  all, then bump or drop the pin. Not a blocker.

### Ruby 4.0.7 baseline failures (2026-09-23)

Found by a fresh resolve (no lockfile) with
`rvm 4.0.7 do bundle install`, then `bundle exec rake` and
`bundle exec rspec`. Each failure was worked around
temporarily to see the next one, and every workaround was
reverted. Listed in the order they fail. Fix them in this
order, one commit each. Failures 1 (`nmatrix` does not
build) and 2 (`rake ~> 10.1` cannot start) are fixed; see
`changelog.md`.

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
