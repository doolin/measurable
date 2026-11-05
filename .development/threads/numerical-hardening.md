# Thread: numerical hardening and property testing

Paused 2026-09-24, before a context compaction. Resume from
here. The durable records are `todo.md`, `backlog.md`,
`changelog.md` (with its defect ledger, count 14), `adr.md`,
`lessons-learned.md`, and `plans/testing-research.md`. This
file holds only what those don't: where the work stopped and
how the operator wants it run.

## Where it stopped

- Last commit: `8d52104` (prop_check and the metric-axiom
  property specs). It is local; the operator pushes. CI was
  green on the previous push (`e2fca44`).
- Suite: 173 examples, 0 failures. RuboCop clean.
- Active in `todo.md`: property testing with `prop_check`.
  Two boxes are ticked. Still open:
  - decide which properties each measure owes, and which
    "distances" are not metrics;
  - special-value runs, blocked on the NaN-policy decision.
- Suggested next, the operator's choice between:
  - the Haversine antipode defect: clamp `a` to [0, 1],
    spec first, ledger entry 15;
  - the per-measure property table, which extends
    `spec/metric_properties_spec.rb` to the other measures.
- Also in the backlog: Euclidean overflow (reuse the scaled
  norm from `minkowski` and `cosine_unit_vector`), KL NaN when
  pᵢ = 0, and decisions on NaN policy, Jaccard semantics,
  Maxmin's domain and `Performance/Sum`.

## How the operator wants the work run

- **Every `git commit` stops for approval.** It is a
  deliberate hook (`.claude/hooks/commit-confirm.sh`). Never
  route around it or propose removing it. Make one commit per
  finished unit, not a string of small ones.
- **Keep other prompts to near zero.** `.claude/settings.local.json`
  allows `rvm *`, read-only git plus `git add`, index-audit,
  watch-ci, `gh run list/view`, WebSearch and WebFetch.
  Anything else prompts, so avoid novel command shapes.
- **Research agents** run locally with WebSearch and WebFetch
  only: no Bash, no `gh api`. The Agent tool's
  `isolation: "remote"` is not available here; it silently
  ran as a local agent and prompted.
- Run commands as `rvm 4.0.7 do …`. The agent shell does not
  pick up `.ruby-version`.
- Edit files, then `git add` in a *later* message. Running
  them in parallel raced several times and left edits
  unstaged.
- Commit bodies state the change and why, with no narration.
  Method that matters goes into `lessons-learned.md` as
  principles.
- Per fix: a spec that fails on the current code, then the
  fix, then a differential check, then a ledger entry, all
  in one commit.

## Scratch tools (session scratchpad, not in the repo)

These live in the session scratchpad and are lost when the
session ends; recreate them from the description if needed.
The backlog's golden-output item is to bring them into the
repo.

- `differential.rb`: seeded inputs to every measure, each
  result printed with `Float#inspect`. Run it with
  `ruby -I<lib> differential.rb <out>` against two trees and
  byte-compare the outputs. The last baseline is
  `out-cosine.txt`, which matches the state after `715f510`.
- `stress.rb`: the extreme-input probes behind the backlog
  findings.
- Unanswered: the operator's 2016 `Gemfile.lock` is set
  aside as `Gemfile.lock.2016` in the scratchpad. The
  operator has not said whether to keep it.
