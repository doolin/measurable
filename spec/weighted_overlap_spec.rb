describe 'WeightedOverlap distance' do
  before :all do
    @data = [
      %i[a a a],
      %i[a a b],
      %i[a a c],
      %i[a b d],
      %i[a b e],
      %i[a c f],
      %i[a c g]
    ]
    @labels = %i[
      c1 c1 c1 c2 c2 c3 c3
    ]
  end

  it 'can be created' do
    expect do
      Measurable::WeightedOverlap.new([[1, 1, 1]], [:label])
    end.not_to raise_error
  end

  it 'calculates information gain weighting' do
    wo = Measurable::WeightedOverlap.new(@data, @labels)
    p1 = wo.feature_indexes[0].probability(:a, :c1)
    p2 = wo.feature_indexes[0].probability(:g, :c1)
    expect(p1).to be_within(1e-5).of(3 / 7.0)
    expect(p2).to be_within(1e-5).of(0.0)

    w = wo.weights
    expect(w[0]).to be_within(1e-5).of(0.0)
    expect(w[1]).to be_within(1e-1).of(1.5) # 1.5566567
    expect(w[2]).to be_within(1e-5).of(w[1])
  end

  it 'calculates information gain ratio weighting' do
    wo = Measurable::WeightedOverlap.new(@data, @labels, ratio: true)
    p1 = wo.feature_indexes[0].probability(:a, :c1)
    p2 = wo.feature_indexes[0].probability(:g, :c1)
    expect(p1).to be_within(1e-5).of(3 / 7.0)
    expect(p2).to be_within(1e-5).of(0.0)

    w = wo.weights
    expect(w[0]).to be_within(1e-5).of(0.0)
    expect(w[1]).to be_within(1e-5).of(1.0)
    expect(w[2]).to be_within(1e-1).of(0.5) # 0.55449231
  end

  it 'contributes nothing for a matching feature' do
    wo = Measurable::WeightedOverlap.new(@data, @labels)
    expect(wo.feature_contribution(:b, :b, 1)).to eq 0.0
  end

  it 'contributes the feature weight for a mismatched feature' do
    wo = Measurable::WeightedOverlap.new(@data, @labels)
    expect(wo.feature_contribution(:b, :c, 1)).to eq wo.weights[1]
  end

  it 'sums the feature contributions into the distance' do
    wo = Measurable::WeightedOverlap.new(@data, @labels)
    a = %i[a c b]
    b = %i[g b c]
    # Sum left to right, as distance does; Array#sum compensates and can
    # differ in the last bit.
    contributions = a.zip(b).each_with_index.reduce(0.0) do |acc, ((x, y), i)|
      acc + wo.feature_contribution(x, y, i)
    end
    expect(wo.distance(a, b)).to eq contributions
  end

  it 'calculates weighted distance' do
    wo = Measurable::WeightedOverlap.new(@data, @labels)
    d = wo.distance(%i[a c b], %i[g b c])
    w = wo.weights
    expect(d).to be_within(1e-5).of(w[1] + w[2])
  end
end
