# Property, mutation, and stress testing: research

Gathered 2026-09-24 from primary sources (repositories,
rubygems.org, official docs, licence files). Every claim
carries the URL it was checked at. Anything that could not be
confirmed is listed under *Unverified* at the end. Versions
and dates are as of 2026-09-24; check them again before
adopting anything.

## Recommendation

- **Property testing: `prop_check`.** It is the only mature
  Ruby library whose float generator deliberately produces
  NaN, ±Infinity, ±Float::MAX, ±Float::MIN and the smallest
  subnormals, which is exactly what probing these measures
  needs. It shrinks failures, and it works inside RSpec
  without extra setup. Two gaps: its CI stops at Ruby 3.4,
  so this gem's suite would be its first run on 4.0; and no
  generator produces -0.0, so add that case by hand.
- **One to watch: `hegeltest`.** It is an unofficial Ruby
  port of Antithesis's Hegel (the Hypothesis engine). It
  declares Ruby 4.0 support and has Hypothesis-quality float
  generation, but it is at 0.1.x.
- **Mutation testing: `mutant` with `--usage opensource`.**
  It is free for public open-source repositories, supports
  Ruby 4.0, and integrates with RSpec. Its licence is
  proprietary (an EULA) and there is an unresolved question
  about sign-up; see below.
- **Stress testing** needs no library. The measures' known
  failure modes, and the published fixes for them, are in
  the numerical section below. The 2026-09-24 stress probes
  (backlog) already found the failures these references
  predict.

## Property-based testing libraries

### prop_check (Qqwy/ruby-prop_check)

- 1.0.2, 2025-03-14; `required_ruby_version >= 2.5.1`; MIT.
  https://rubygems.org/gems/prop_check
- CI matrix runs Ruby 3.0–3.4, not 4.0.
  https://raw.githubusercontent.com/Qqwy/ruby-prop_check/main/.github/workflows/run_tests.yaml
- Last commits 2025-03-14; nothing since.
  https://github.com/Qqwy/ruby-prop_check/commits/main
- Shrinks; `expect` works inside `forall`, so it fits RSpec
  as is. https://github.com/Qqwy/ruby-prop_check
- Floats
  (https://raw.githubusercontent.com/Qqwy/ruby-prop_check/master/lib/prop_check/generators.rb):
  - `real_float` is finite only ("no infinity, no NaN, no
    numbers testing the limits of floating-point
    arithmetic").
  - `float` mixes in special values about 1 in 50: NaN,
    ±Infinity, ±Float::MAX, ±Float::MIN, ±Float::EPSILON,
    and `0.0.next_float` / `0.0.prev_float` (the smallest
    subnormals). No -0.0.

### rantly (rantly-rb/rantly)

- 3.0.0, 2024-10-21; Ruby >= 3.0.0; MIT.
  https://rubygems.org/gems/rantly
- Master (unreleased 3.1.0) needs Ruby >= 3.3.0; last commit
  2025-06-22. https://github.com/rantly-rb/rantly/commits/master
- RSpec through `rantly/rspec_extensions`. Shrinking is
  opt-in (`rantly/shrinks`) and capped at 1024 operations.
  https://github.com/rantly-rb/rantly
- `float` is `rand` in [0, 1), or a sum of six `rand`s. It
  never produces NaN, Infinity, -0.0, subnormals or large
  magnitudes.
  https://raw.githubusercontent.com/rantly-rb/rantly/master/lib/rantly/generator.rb

### pbt (ohbarye/pbt)

- 0.7.0, 2026-04-04; Ruby >= 3.1; MIT.
  https://rubygems.org/gems/pbt
- CI runs Ruby 3.1–4.0, with 4.0 added in 0.6.0; last commit
  2026-08-23.
  https://raw.githubusercontent.com/ohbarye/pbt/main/.github/workflows/main.yml
- Shrinks. No dedicated RSpec integration, and its Ractor
  worker mode cannot call `expect`.
  https://github.com/ohbarye/pbt
- `float` is `x.to_f / (|y| + 1)` for integers x, y in
  ±1,000,000. So magnitudes are at most 1e6, and there is no
  NaN, Infinity or subnormal.
  https://raw.githubusercontent.com/ohbarye/pbt/main/lib/pbt/arbitrary/constant.rb

### Hypothesis and Hegel

- `hypothesis-specs` 0.7.1 (2021) is dead: the repository
  is an archived prototype, and its native binding no longer
  builds. https://github.com/HypothesisWorks/hypothesis-ruby ,
  https://github.com/HypothesisWorks/hypothesis/issues/2681
- Official Hegel covers Rust, Go, TypeScript, OCaml, C++ and
  Java, with no Ruby. https://antithesis.com/blog/2026/hegel/ ,
  https://github.com/hegeldev
- Unofficial Ruby port `hegeltest` 0.1.1 (2026-08-31, Ruby
  >= 3.3, MIT):
  - Its README claims Ruby 4.0 support. It ships a prebuilt
    `libhegel` binary per platform and needs only FFI.
  - RSpec through `config.include Hegel::Syntax::Methods`.
  - `floats` takes `allow_nan`, `allow_infinity`, bounds, and
    an unrestricted smallest magnitude, so subnormals are
    possible.
  - https://rubygems.org/gems/hegeltest ,
    https://github.com/meganemura/hegel-ruby

## Mutation testing

### mutant (mbj/mutant)

- 0.17.0, 2026-09-17, with a matching `mutant-rspec`.
  https://rubygems.org/gems/mutant ,
  https://rubygems.org/gems/mutant-rspec
- Ruby: the gemspecs need >= 3.3. The README's support table
  lists 3.2 through 4.0. The two agree on 4.0.
  https://raw.githubusercontent.com/mbj/mutant/main/README.md
- **Licence: proprietary.** The LICENSE is an end-user
  licence agreement with Schirp DSO Ltd, under Maltese law.
  https://raw.githubusercontent.com/mbj/mutant/main/LICENSE
  - §1.2: "If you subscribed under the Free Project License
    you may use the software for any of your projects that
    are released under an Open Source License that is hosted
    on a public source code repository."
  - README: "Free for open source. Use `--usage opensource`
    for public repositories." Commercial use is $30 per
    developer per month.
  - Open question: the EULA's "subscribed" wording suggests
    a sign-up, which the README does not describe.
- Invocation, from the README:
  `mutant run --use rspec --usage opensource --require ./lib/person 'Person#adult?'`.
- Configuration goes in `.mutant.yml`. For this gem, roughly:
  `includes: [lib]`, `requires: [measurable]`,
  `integration: {name: rspec}`, subject `'Measurable*'`.
  https://github.com/mbj/mutant/blob/main/docs/configuration.md
- 0.17.0 adds test selection driven by SimpleCov coverage.
  https://raw.githubusercontent.com/mbj/mutant/main/Changelog.md

### Alternatives (young, MIT)

- `evilution` 1.2.0 (2026-09-21, Ruby >= 3.3; first visible
  version 2026-06-16). https://rubygems.org/gems/evilution
- `mutineer` 1.0.2 (2026-09-21, Ruby >= 3.4, Prism plus
  stdlib only; its README says it detects RSpec).
  https://rubygems.org/gems/mutineer ,
  https://github.com/davidteren/mutineer

## Numerical robustness

- **Norm overflow and underflow.** Goldberg's "Infinity"
  section shows √(x²+y²) overflowing at x = 3×10⁷⁰,
  y = 4×10⁷⁰, although 5×10⁷⁰ is representable.
  https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html
  - LAPACK's `nrm2` accumulates in three scaled bins (Blue
    1978; Anderson, "Algorithm 978: Safe Scaling in the
    Level 1 BLAS", TOMS 2017).
    https://www.netlib.org/lapack/explore-html/d1/d2a/group__nrm2_ga7f9f9febc6dc1836c9f5e7c1aa00b743.html ,
    https://dl.acm.org/doi/10.1145/3061665
  - Ruby's `Math.hypot` takes only two arguments, so an
    n-dimensional norm needs its own scaling.
    https://docs.ruby-lang.org/en/master/Math.html
  - This gem now scales by the largest component, in
    `minkowski` and in cosine's unit vectors.
- **Summation.** Ruby's `Array#sum` uses Kahan–Babuska
  (Neumaier) compensated summation for Floats, adopted in
  2016 (r57001). https://bugs.ruby-lang.org/issues/12871
  - Neumaier gives 2.0 on [1, 1e100, 1, −1e100], where Kahan
    gives 0.0. Error bound: |E| ≤ (2ε + O(nε²)) Σ|xᵢ|.
    https://en.wikipedia.org/wiki/Kahan_summation_algorithm
  - Background: Higham, *Accuracy and Stability of Numerical
    Algorithms*, 2nd ed., SIAM 2002, has a chapter on
    summation. https://nhigham.com/accuracy-and-stability-of-numerical-algorithms/
  - This is the basis for the `Performance/Sum` decision in
    the backlog: switching `reduce(:+)` to `sum` is an
    accuracy improvement that changes the last bits of
    results.
- **Cosine for nearly parallel vectors.** 1 − cos is
  catastrophic cancellation (Goldberg, "Cancellation").
  - Cancellation-free distance: ‖â − b̂‖²/2 for unit vectors.
    https://en.wikipedia.org/wiki/Cosine_similarity
  - Kahan's angle formula:
    θ = 2·atan(‖‖y‖x − ‖x‖y‖ / ‖‖y‖x + ‖x‖y‖).
    https://people.eecs.berkeley.edu/~wkahan/Mindless.pdf ,
    confirmed through
    https://possiblywrong.wordpress.com/2020/07/17/computing-the-angle-between-two-vectors/
  - Cosine distance adopted the ‖â − b̂‖²/2 form in
    `715f510`.
- **Haversine.** h nears 1 only at antipodes, where rounding
  errors grow; clamp h to at most 1 before the square root
  (Sinnott 1984). https://en.wikipedia.org/wiki/Haversine_formula
  - It beats the spherical law of cosines for small
    separations. The spherical model itself is off by up to
    about 0.3–0.5%.
    https://www.movable-type.co.uk/scripts/latlong.html
  - In Ruby, `Math.sqrt` of a negative raises
    `Math::DomainError`, where C would return NaN.
    https://docs.ruby-lang.org/en/master/Math/DomainError.html
  - Vincenty fails to converge near antipodes; Karney (2013)
    converges everywhere.
    https://en.wikipedia.org/wiki/Vincenty%27s_formulae
- **Kullback–Leibler.** A term with pᵢ = 0 is 0 (the limit
  of x log x). qᵢ = 0 with pᵢ > 0 gives +∞.
  https://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence
  - SciPy's `rel_entr`: x·log(x/y) for x, y > 0; 0 for
    x = 0, y ≥ 0; ∞ otherwise.
    https://docs.scipy.org/doc/scipy/reference/generated/scipy.special.rel_entr.html

## Unverified

- The exact wording and page of Kahan's formula in
  Mindless.pdf (the PDF would not render; confirmed only
  second-hand).
- Whether Ruby 4.0's `array.c` still has the same
  Kahan–Babuska loop (checked only in the 2.5.5 source).
- Which Ruby release first shipped r57001.
- Chapter numbers in Higham; Blue 1978 and Cover & Thomas
  were not fetched.
- `hegeltest`'s shrinking, and whether it generates -0.0.
- Ruby 4.0 support for `prop_check` and `rantly`: no
  evidence either way.
- Whether mutant's free licence needs a sign-up beyond
  `--usage opensource`, and what it does without the flag.
