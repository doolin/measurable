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

  it 'calculates weighted distance' do
    wo = Measurable::WeightedOverlap.new(@data, @labels)
    d = wo.distance(%i[a c b], %i[g b c])
    w = wo.weights
    expect(d).to be_within(1e-5).of(w[1] + w[2])
  end
end
