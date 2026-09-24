# Stewardship

Standing maintenance — recurring, identical-in-kind work
(dependency updates, consistency sweeps, doc-drift checks).
One `##` section per activity: what it covers, its
guardrails, and a dated log line per pass. These sections are
never "done."

## Dependency updates

Run `~/.claude/skills/gem-update/gem-update` from the repo
root. It sorts outdated gems into patch, minor and major.
It applies the patch bumps in one batch, then runs
bundler-audit, rubocop and rspec.

Guardrails:

- Minor and major bumps go one at a time, with the specs run
  after each.
- `Gemfile.lock` is git-ignored, so a lockfile diff alone has
  nothing to commit. A pass lands as a gemspec change when a
  version limit has to move, and otherwise only as a log
  line here.
- Not usable until the Ruby 4.0.7 revival (roadmap milestone
  1) makes the bundle install.

Log:

<!-- "- YYYY-MM-DD — outcome" per pass, newest first. -->
