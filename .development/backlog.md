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
  dead. Add a workflow that runs `bundle exec rake` on Ruby
  4.0, the gemspec's floor (see `adr.md`). Roadmap
  milestone 2.
- **Gemspec metadata** — Point authors, email and homepage at the fork
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
