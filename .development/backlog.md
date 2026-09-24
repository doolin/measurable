# Backlog

Items not yet scheduled. Add new work here. Move to `todo.md`
when it becomes active.

<!-- Newest items at the top. -->

- **Bring RuboCop forward** — `.rubocop.yml` is a 2016
  `--auto-gen-config` todo file (RuboCop 0.39), and current
  RuboCop refuses to start on it: `Metrics/LineLength`,
  `Style/UnneededPercentQ`, `Style/VariableName` and the
  `Performance/*` cops were moved, renamed, or split out
  into `rubocop-performance`. Regenerate the todo under
  current RuboCop (`plugins:` for `rubocop-performance` and
  `rubocop-rspec`, `TargetRubyVersion: 4.0`), work through
  the offenses, then add a RuboCop step to
  `.github/workflows/ci.yml`. Checked 2026-09-23.
- **Refresh the README** — It still names NMatrix as
  supported (lines 7–12, 63, 72), shows a dead Travis badge
  and a Code Climate badge for `agarie/measurable`, and
  claims testing on MRI 1.9.3–2.1 and Rubinius. Rewrite
  those passages to match the fork and Ruby 4, and keep the
  credit to `reddavis`. Roadmap milestone 1.
