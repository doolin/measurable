describe Measurable::Levenshtein do
  it 'can be extended separately' do
    klass = Class.new do
      extend Measurable::Levenshtein
    end

    expect(klass.levenshtein('ab', 'abc')).to eq 1
  end

  it 'can be included separately' do
    klass = Class.new do
      include Measurable::Levenshtein
    end

    expect(klass.new.levenshtein('ab', 'abc')).to eq 1
  end

  context 'strings' do
    it 'handles empty' do
      expect(Measurable.levenshtein('', '')).to eq 0
      expect(Measurable.levenshtein('', 'abcd')).to eq 4
      expect(Measurable.levenshtein('abcd', '')).to eq 4
    end

    it 'does not count equality' do
      expect(Measurable.levenshtein('aa', 'aa')).to eq 0
    end

    it 'counts deletion' do
      expect(Measurable.levenshtein('ab', 'a')).to eq 1
    end

    it 'counts insertion' do
      expect(Measurable.levenshtein('ab', 'abc')).to eq 1
    end

    it 'counts substitution' do
      expect(Measurable.levenshtein('aa', 'ab')).to eq 1
    end
  end

  context 'known answers' do
    {
      %w[kitten sitting] => 3,
      %w[sitting kitten] => 3,
      %w[saturday sunday] => 3,
      %w[flaw lawn] => 2,
      %w[intention execution] => 5,
      %w[a b] => 1,
      %w[ab ba] => 2,
      %w[abcd b] => 3,
      %w[b abcd] => 3,
      %w[abc xyz] => 3
    }.each do |(a, b), distance|
      it "is #{distance} for #{a.inspect} and #{b.inspect}" do
        expect(Measurable.levenshtein(a, b)).to eq distance
      end

      it "is #{distance} for the character arrays of #{a.inspect} and #{b.inspect}" do
        expect(Measurable.levenshtein(a.chars, b.chars)).to eq distance
      end
    end
  end

  context 'metric properties on random strings' do
    let(:words) do
      rng = Random.new(1_729)
      Array.new(40) { Array.new(rng.rand(0..7)) { %w[a b c].sample(random: rng) }.join }
    end
    let(:pairs) { words.combination(2).to_a }
    let(:triples) { words.first(15).combination(3).to_a }

    it 'is symmetric' do
      asymmetric = pairs.reject { |a, b| Measurable.levenshtein(a, b) == Measurable.levenshtein(b, a) }
      expect(asymmetric).to be_empty
    end

    it 'lies between the length difference and the longer length' do
      out_of_bounds = pairs.reject do |a, b|
        Measurable.levenshtein(a, b).between?((a.size - b.size).abs, [a.size, b.size].max)
      end
      expect(out_of_bounds).to be_empty
    end

    it 'satisfies the triangle inequality' do
      violations = triples.reject do |a, b, c|
        Measurable.levenshtein(a, c) <= Measurable.levenshtein(a, b) + Measurable.levenshtein(b, c)
      end
      expect(violations).to be_empty
    end
  end

  context 'arrays' do
    it 'handles empty' do
      expect(Measurable.levenshtein([], [])).to eq 0
      expect(Measurable.levenshtein([], %w[a b c d])).to eq 4
      expect(Measurable.levenshtein(%w[a b c d], [])).to eq 4
    end

    it 'does not count equality' do
      expect(Measurable.levenshtein(%w[a], %w[a])).to eq 0
    end

    it 'counts deletion' do
      expect(Measurable.levenshtein(%w[a b], %w[a])).to eq 1
    end

    it 'counts insertion' do
      expect(Measurable.levenshtein(%w[a b], %w[a b c])).to eq 1
    end

    it 'counts substitution' do
      expect(Measurable.levenshtein(%w[a a], %w[a b])).to eq 1
    end
  end
end
