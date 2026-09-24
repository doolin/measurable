describe 'Interface for distance functions' do
  before :all do
    @u = "Hi, I'm a test string!"
    @v = 'Hello, not a test omg.'
    @x = [1, 1]
    @y = [2, 2]
  end

  it 'creates object from measure label' do
    obj = nil
    expect { obj = Measurable.object_for(:euclidean) }.not_to raise_error
  end

  it 'calculates euclidean distance' do
    obj = Measurable.object_for(:euclidean)
    d = @x.distance(@y, obj)
    expect(d).to be_within(0.1).of(2**0.5)
  end

  it 'calculates overlap distance' do
    d = [1, 5].distance([2, 2]) { |u, v| u.zip(v).reduce(0) { |sum, (a, b)| sum + (a - b).abs } }
    expect(d).to be(4)
  end

  it 'raises ArgumentError when no measure is given or set' do
    # Exact message: UncaughtThrowError (from `throw`) subclasses
    # ArgumentError, and its message only contains this text.
    expect { [1, 1].distance([2, 2]) }.to raise_error(
      an_instance_of(ArgumentError).and(having_attributes(message: 'No measure specified'))
    )
  end

  it 'calculates hamming distance with string' do
    # Extending string to be measurable
    class String
      include Measurable::MeasurableObject

      def coordinates
        self
      end
    end
    @u.measure = Measurable.object_for(:hamming)
    d = @u.distance(@v)
    expect(d).to be(17)
  end

  it 'creates measure object' do
    mClass = Class.new do
      include Measurable::Euclidean

      alias_method :distance, :euclidean
    end
    obj = mClass.new
    @x.measure = obj
    d = @x.distance @y
    expect(d).to be_within(0.1).of(2**0.5)
  end
end
