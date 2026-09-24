require 'prop_check'

describe 'Euclidean' do
  before :all do
    @u = [1, 3, 16]
    @v = [1, 4, 16]
    @w = [4, 5, 6]
  end

  context 'Distance' do
    it 'accepts two arguments' do
      expect { Measurable.euclidean(@u, @v) }.not_to raise_error
      expect { Measurable.euclidean(@u, @v, @w) }.to raise_error(ArgumentError)
    end

    it "accepts one argument and returns the vector's norm" do
      # Remember that 3^2 + 4^2 = 5^2.
      expect(Measurable.euclidean([3, 4])).to eq 5
    end

    it 'is symmetric' do
      expect(Measurable.euclidean(@u, @v)).to eq Measurable.euclidean(@v, @u)
    end

    it 'returns the correct value' do
      expect(Measurable.euclidean(@u, @u)).to eq 0
      expect(Measurable.euclidean(@u, @v)).to eq 1
    end

    it 'raises ArgumentError with vectors of different length' do
      expect { Measurable.euclidean(@u, [2, 2, 2, 2]) }.to raise_error(ArgumentError)
    end

    context 'with extreme magnitudes' do
      # The plain sum of squares overflows above about 1e154 and loses
      # everything below about 1e-162, though the distance is representable.
      it 'does not overflow' do
        expect(Measurable.euclidean([1e200, 1e200])).to be_within(2e200 * Float::EPSILON).of(Math.sqrt(2) * 1e200)
        expect(Measurable.euclidean([1e200, 0.0], [-1e200, 0.0])).to eq 2e200
      end

      it 'does not underflow' do
        expect(Measurable.euclidean([3e-200, 4e-200])).to be_within(5e-200 * Float::EPSILON).of(5e-200)
      end

      it 'keeps full precision for subnormal components' do
        expect(Measurable.euclidean([3e-310, 4e-310])).to be_within(Float::MIN * Float::EPSILON).of(5e-310)
      end

      it 'scales exactly with a power of two, up to rounding' do
        g = PropCheck::Generators
        vectors = g.array(g.choose(-1_000_000..1_000_000).map(&:to_f), min: 1, max: 8)
        PropCheck.forall(vectors, g.one_of(g.constant(-500), g.constant(500))) do |x, k|
          norm = Measurable.euclidean(x)
          scaled = Measurable.euclidean(x.map { |xi| xi * (2.0**k) })
          expect(scaled).to be_within(4 * Float::EPSILON * norm * (2.0**k)).of(norm * (2.0**k))
        end
      end

      it 'returns Infinity for an infinite component' do
        expect(Measurable.euclidean([Float::INFINITY, 1.0])).to eq Float::INFINITY
      end

      it 'propagates NaN' do
        expect(Measurable.euclidean([Float::NAN, 1.0])).to be_nan
      end
    end

    it 'can be extended separately' do
      klass = Class.new do
        extend Measurable::Euclidean
      end

      expect(klass.euclidean([3, 4])).to eq 5
    end

    it 'can be included separately' do
      klass = Class.new do
        include Measurable::Euclidean
      end

      expect(klass.new.euclidean([3, 4])).to eq 5
    end
  end

  context 'Squared Distance' do
    it 'accepts two arguments' do
      expect { Measurable.euclidean_squared(@u, @v) }.not_to raise_error
      expect { Measurable.euclidean_squared(@u, @v, @w) }.to raise_error(ArgumentError)
    end

    it "accepts one argument and returns the vector's norm" do
      # Remember that 3^2 + 4^2 = 5^2.
      expect(Measurable.euclidean_squared([3, 4])).to eq 25
    end

    it 'is symmetric' do
      x = Measurable.euclidean_squared(@u, @v)
      y = Measurable.euclidean_squared(@v, @u)

      expect(x).to eq y
    end

    it 'returns the correct value' do
      expect(Measurable.euclidean_squared(@u, @u)).to eq 0
      expect(Measurable.euclidean_squared(@u, @v)).to eq 1
    end

    it 'raises ArgumentError with vectors of different length' do
      expect { Measurable.euclidean_squared(@u, [2, 2, 2, 2]) }.to raise_error(ArgumentError)
    end
  end
end
