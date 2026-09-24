# Roadmap

Project direction: where this is going, the shape it is
converging on, and the milestones on the way. One per
project. Current priorities live here; backlog items should
trace to something in this file. Update when the destination
changes, not for every step.

## Direction

`measurable` is the family's kit of distance and similarity
measures: the instruments an experiment uses to compare
datasets. It has not been touched since about 2016. The
first job is to make it install and pass its specs on a
current Ruby. Only after that is the question of which
measures to add, or how to make the existing ones
numerically trustworthy, worth asking.

## Milestones

1. **Revival on Ruby 4.0.7.** `bundle install` succeeds and
   `bundle exec rake` passes, with a modern gemspec and no
   dependency the code does not use. Landed 2026-09-23.
2. **Green CI.** A GitHub Actions workflow replaces the
   defunct `.travis.yml` and runs the specs on each push.
   Landed 2026-09-24 (run 35989298688, on `a929169`).
3. **Recurring upkeep.** `gem-update` passes are logged in
   `stewardship.md`.
