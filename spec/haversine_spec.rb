describe 'Haversine distance' do
  before :all do
    # We have very big errors in this formula, due to:
    #   - The Earth is considered a sphere.
    #   - Earth's radius is considered constant (same as above).
    #
    # Given these conditions, I'll just assume the error to be less than 1.
    # TODO: Calculate better error estimates.
    @haversine_tolerance = 1

    @u = [35.66667, 139.75] # Tokyo: 35 40' N, 139 45' E.
    @v = [-23.53333, -46.61667] # São Paulo: 23 32' S, 46 37' W.
  end

  it 'accepts two arguments' do
    expect { Measurable.haversine(@u, @v) }.not_to raise_error
    expect { Measurable.haversine(@u, @v, [-24.5, 40.23]) }.to raise_error(ArgumentError)
  end

  it 'is symmetric' do
    x = Measurable.haversine(@u, @v)
    y = Measurable.haversine(@v, @u)

    expect(x).to be_within(TOLERANCE).of(y)
  end

  it 'returns the correct value' do
    x = Measurable.haversine(@u, @v, :km)

    expect(x).to be_within(@haversine_tolerance).of(18_533)
  end

  context 'with consistent units' do
    let(:km) { Measurable.haversine(@u, @v, :km) }

    it 'gives meters as 1000 times kilometers' do
      expect(Measurable.haversine(@u, @v, :meters)).to be_within(1e-9 * km * 1000).of(km * 1000)
    end

    it 'gives miles as kilometers over 1.609344' do
      expect(Measurable.haversine(@u, @v, :miles)).to be_within(1e-12 * km).of(km / 1.609344)
    end

    it 'gives feet as 5280 times miles' do
      miles = Measurable.haversine(@u, @v, :miles)
      expect(Measurable.haversine(@u, @v, :feet)).to be_within(1e-12 * miles * 5280).of(miles * 5280)
    end
  end

  context 'with antipodal points' do
    let(:half) { Math::PI * 6371 }

    # Rounding can push the haversine term a just past 1 here, and
    # Math.sqrt(1 - a) then raises Math::DomainError.
    it 'returns half the circumference' do
      expect(Measurable.haversine([-82.0, 0.0], [82.0, -180.0], :km)).to be_within(4 * Float::EPSILON * half).of(half)
    end

    it 'is accurate to a few ulps at every latitude' do
      (-90..90).each do |lat|
        expect(Measurable.haversine([lat, 45.0], [-lat, -135.0], :km))
          .to be_within(4 * Float::EPSILON * half).of(half)
      end
    end

    # A step of d along the meridian from the antipode leaves pi - d.
    it 'resolves a millimeter from the antipode' do
      step = 1e-8 # degrees, about 1.1 mm
      expect(Measurable.haversine([30.0, 0.0], [-30.0 + step, 180.0], :km))
        .to be_within(4 * Float::EPSILON * half).of((Math::PI - (step * Measurable::RAD_PER_DEG)) * 6371)
    end
  end

  context 'with the classic formula' do
    let(:half) { Math::PI * 6371 }

    it 'does not raise at the antipode' do
      expect(Measurable.haversine([-82.0, 0.0], [82.0, -180.0], :km, formula: :classic)).to eq(half)
    end

    # Near a = 1, 1 - a keeps only half the digits, so the error is of
    # order sqrt(epsilon) times the distance.
    it 'is accurate to sqrt(epsilon) near the antipode' do
      (-90..90).each do |lat|
        expect(Measurable.haversine([lat, 45.0], [-lat, -135.0], :km, formula: :classic))
          .to be_within(Math.sqrt(Float::EPSILON) * half).of(half)
      end
    end

    it 'agrees with the default away from the antipode' do
      expect(Measurable.haversine(@u, @v, :km, formula: :classic))
        .to be_within(16 * Float::EPSILON * 18_533).of(Measurable.haversine(@u, @v, :km))
    end
  end

  it 'rejects an unknown formula' do
    expect { Measurable.haversine(@u, @v, :km, formula: :vincenty) }
      .to raise_error(ArgumentError, 'formula must be :split or :classic, got :vincenty')
  end

  it 'only works with [lat, long] vectors' do
    expect { Measurable.haversine([2, 4], [1, 3, 5, 7]) }.to raise_error(ArgumentError)
  end

  it 'can be extended separately' do
    klass = Class.new do
      extend Measurable::Haversine
    end

    x = klass.haversine(@u, @v, :km)
    expect(x).to be_within(@haversine_tolerance).of(18_533)
  end

  it 'can be included separately' do
    klass = Class.new do
      include Measurable::Haversine
    end

    x = klass.new.haversine(@u, @v, :km)
    expect(x).to be_within(@haversine_tolerance).of(18_533)
  end
end
