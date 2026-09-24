describe 'Minkowski' do
  before :all do
    @u = [1, 3, 6]
    @v = [1, 4, 7]
    @w = [4, 5, 6]
  end

  context 'Distance' do
    it 'accepts two arguments' do
      expect { Measurable.minkowski(@u, @v) }.not_to raise_error
      expect { Measurable.minkowski(@u, @v, @w) }.to raise_error(ArgumentError)
    end

    it 'is symmetric' do
      expect(Measurable.minkowski(@u, @v)).to eq Measurable.minkowski(@v, @u)
    end

    it 'returns the correct value' do
      expect(Measurable.minkowski(@u, @u)).to eq 0
      expect(Measurable.minkowski(@u, @v)).to eq 2
    end

    it 'does not work with vectors of different length' do
      expect { Measurable.minkowski(@u, [2, 2, 2, 2]) }.to raise_error(ArgumentError)
    end

    it 'can be extended separately' do
      klass = Class.new do
        extend Measurable::Minkowski
      end

      expect(klass.minkowski(@u, @u)).to eq 0
    end

    it 'can be included separately' do
      klass = Class.new do
        include Measurable::Minkowski
      end

      expect(klass.new.minkowski(@u, @u)).to eq 0
    end
  end

  context 'with an order p' do
    let(:vectors) do
      rng = Random.new(3_141)
      Array.new(200) do
        n = rng.rand(1..8)
        [Array.new(n) { rng.rand(-10.0..10.0) }, Array.new(n) { rng.rand(-10.0..10.0) }]
      end
    end

    it 'defaults to p = 1, the city-block distance' do
      expect(Measurable.minkowski(@u, @w, 1)).to eq Measurable.minkowski(@u, @w)
    end

    it 'gives the known answer for p = 3' do
      expect(Measurable.minkowski([0, 0], [3, 4], 3)).to be_within(1e-15 * 4.5).of(91**(1.0 / 3))
    end

    it 'agrees with the Euclidean distance at p = 2' do
      mismatched = vectors.reject do |u, v|
        e = Measurable.euclidean(u, v)
        (Measurable.minkowski(u, v, 2) - e).abs <= 4 * Float::EPSILON * e
      end
      expect(mismatched).to be_empty
    end

    it 'equals the Chebyshev distance at p = Infinity' do
      mismatched = vectors.reject do |u, v|
        Measurable.minkowski(u, v, Float::INFINITY) == Measurable.chebyshev(u, v)
      end
      expect(mismatched).to be_empty
    end

    it 'does not increase as p increases' do
      orders = [1, 1.5, 2, 3, 10, Float::INFINITY]
      increasing = vectors.reject do |u, v|
        d = orders.map { |p| Measurable.minkowski(u, v, p) }
        d.each_cons(2).all? { |a, b| b <= a * (1 + (4 * Float::EPSILON)) }
      end
      expect(increasing).to be_empty
    end

    it 'does not overflow where the sum of squares would' do
      expect(Measurable.minkowski([1e200, 1e200], [0, 0], 2)).to be_within(1e-15 * 1.5e200).of(Math.hypot(1e200, 1e200))
    end

    it 'does not underflow where the sum of squares would' do
      expect(Measurable.minkowski([3e-200, 4e-200], [0, 0], 2)).to be_within(1e-15 * 5e-200).of(5e-200)
    end

    it 'is zero for identical vectors' do
      expect(Measurable.minkowski([1.5, -2.0], [1.5, -2.0], 3)).to eq 0.0
    end

    it 'rejects an order that is not a positive number' do
      [0, -1, Float::NAN, 'two', [2]].each do |p|
        expect { Measurable.minkowski([1, 2], [3, 4], p) }
          .to raise_error(ArgumentError, /order p must be a positive number/)
      end
    end
  end
end
