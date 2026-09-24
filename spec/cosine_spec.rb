describe 'Cosine' do
  context 'Similarity' do
    before :all do
      @u = [1, 2]
      @v = [2, 3]
      @w = [4, 5]
    end

    it 'accepts two arguments' do
      expect { Measurable.cosine_similarity(@u, @v) }.not_to raise_error
      expect { Measurable.cosine_similarity(@u, @v, @w) }.to raise_error(ArgumentError)
    end

    it 'is symmetric' do
      x = Measurable.cosine_similarity(@u, @v)
      y = Measurable.cosine_similarity(@v, @u)
      expect(x).to be_within(TOLERANCE).of(y)
    end

    it 'returns the correct value' do
      x = Measurable.cosine_similarity(@u, @v)
      expect(x).to be_within(TOLERANCE).of(0.992277877)
    end

    it 'raises ArgumentError with vectors of different length' do
      expect { Measurable.cosine_similarity(@u, [1, 3, 5, 7]) }.to raise_error(ArgumentError)
    end

    it 'can be extended separately' do
      klass = Class.new do
        extend Measurable::Cosine
      end
      x = klass.cosine_similarity(@u, @v)
      expect(x).to be_within(TOLERANCE).of(0.992277877)
    end

    it 'can be extended separately' do
      klass = Class.new do
        include Measurable::Cosine
      end
      x = klass.new.cosine_similarity(@u, @v)
      expect(x).to be_within(TOLERANCE).of(0.992277877)
    end
  end

  context 'Distance' do
    before :all do
      @u = [1, 2]
      @v = [2, 3]
      @w = [4, 5]
    end

    it 'accepts two arguments' do
      expect { Measurable.cosine_distance(@u, @v) }.not_to raise_error
      expect { Measurable.cosine_distance(@u, @v, @w) }.to raise_error(ArgumentError)
    end

    it 'is symmetric' do
      x = Measurable.cosine_distance(@u, @v)
      y = Measurable.cosine_distance(@v, @u)
      expect(x).to be_within(TOLERANCE).of(y)
    end

    it 'returns the correct value' do
      x = Measurable.cosine_distance(@u, @v)
      # TODO: Use a real example.
      expect(x).to be_within(TOLERANCE).of(1.0 - 0.992277877)
    end

    it 'raises ArgumentError with vectors of different length' do
      expect { Measurable.cosine_distance(@u, [1, 3, 5, 7]) }.to raise_error(ArgumentError)
    end
  end

  context 'with numerically hard inputs' do
    let(:vectors) do
      rng = Random.new(1_414)
      Array.new(2000) { Array.new(rng.rand(2..20)) { rng.rand(-1.0..1.0) } }
    end

    it 'keeps the similarity of a vector with itself within [-1, 1]' do
      out_of_range = vectors.reject { |v| Measurable.cosine_similarity(v, v).between?(-1.0, 1.0) }
      expect(out_of_range).to be_empty
    end

    it 'never gives a negative distance' do
      negative = vectors.select { |v| Measurable.cosine_distance(v, v).negative? }
      expect(negative).to be_empty
    end

    it 'resolves nearly parallel vectors instead of cancelling to zero' do
      # Exact 1 - 1/sqrt(1 + t^2), rearranged so it has no cancellation.
      inaccurate = [1e-4, 1e-6, 1e-8, 1e-9].reject do |t|
        exact = t * t / (Math.sqrt(1 + (t * t)) * (Math.sqrt(1 + (t * t)) + 1))
        got = Measurable.cosine_distance([1.0, 0.0], [1.0, t])
        ((got - exact) / exact).abs < 1e-6
      end
      expect(inaccurate).to be_empty
    end

    it 'gives the extremes for antiparallel vectors, without passing them' do
      s = Measurable.cosine_similarity([1.0, 2.0], [-2.0, -3.9])
      d = Measurable.cosine_distance([1.0, 2.0], [-2.0, -3.9])
      expect([s.between?(-1.0, -1 + 1e-3), d.between?(2 - 1e-3, 2.0)]).to eq [true, true]
    end

    it 'keeps random pairs within [-1, 1] and [0, 2]' do
      pairs = vectors.each_slice(2).select { |u, v| u.size == v.size }
      out_of_range = pairs.reject do |u, v|
        Measurable.cosine_similarity(u, v).between?(-1.0, 1.0) && Measurable.cosine_distance(u, v).between?(0.0, 2.0)
      end
      expect(out_of_range).to be_empty
    end

    it 'does not overflow on huge components' do
      expect(Measurable.cosine_similarity([1e200, 1e200], [1e200, 1e200])).to be_within(4 * Float::EPSILON).of(1.0)
    end

    it 'does not underflow on tiny components' do
      expect(Measurable.cosine_similarity([3e-200, 4e-200], [4e-200, 3e-200])).to be_within(4 * Float::EPSILON).of(0.96)
    end
  end
end
