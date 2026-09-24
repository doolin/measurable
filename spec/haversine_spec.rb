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
