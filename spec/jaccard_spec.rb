describe "Jaccard" do

  context "Index" do
    before :all do
      @u = [1, 0, 1]
      @v = [1, 1, 1]
      @w = [0, 1, 0]
    end

    it "accepts two arguments" do
      expect { Measurable.jaccard_index(@u, @v) }.to_not raise_error
      expect { Measurable.jaccard_index(@u, @v, @w) }.to raise_error(ArgumentError)
    end

    it "should be symmetric" do
      x = Measurable.jaccard_index(@u, @v)
      y = Measurable.jaccard_index(@v, @u)

      expect(x).to be_within(TOLERANCE).of(y)
    end

    it "should return the correct value" do
      x = Measurable.jaccard_index(@u, @v)

      expect(x).to be_within(TOLERANCE).of(1.0 / 2.0)
    end

    it "should work with vectors of different length" do
      expect { Measurable.jaccard_index(@u, [1, 2, 3, 4]) }.to_not raise_error
    end

    it "can be extended separately" do
      klass = Class.new do
        extend Measurable::Jaccard
      end

      x = klass.jaccard_index(@u, @v)

      expect(x).to be_within(TOLERANCE).of(1.0 / 2.0)
    end

    it "can be included separately" do
      klass = Class.new do
        include Measurable::Jaccard
      end

      x = klass.new.jaccard_index(@u, @v)

      expect(x).to be_within(TOLERANCE).of(1.0 / 2.0)
    end

  end

  context "Distance" do
    before :all do
      @u = [1, 0, 1]
      @v = [1, 1, 1]
      @w = [0, 1, 0]
    end

    it "accepts two arguments" do
      expect { Measurable.jaccard_dissimilarity(@u, @v) }.to_not raise_error
      expect { Measurable.jaccard_dissimilarity(@u, @v, @w) }.to raise_error(ArgumentError)
    end

    it "should be symmetric" do
      x = Measurable.jaccard_dissimilarity(@u, @v)
      y = Measurable.jaccard_dissimilarity(@v, @u)

      expect(x).to be_within(TOLERANCE).of(y)
    end

    it "should return the correct value" do
      x = Measurable.jaccard_dissimilarity(@u, @v)

      expect(x).to be_within(TOLERANCE).of(1.0 / 2.0)
    end

    it "should work with vectors of different length" do
      expect { Measurable.jaccard_dissimilarity(@u, [1, 2, 3, 4]) }.to_not raise_error
    end
  end
end
