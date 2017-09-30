RSpec.describe ZZ::Option do
  let(:force) { described_class.new("f", "force", 0, "force something") }
  let(:paths) { described_class.new("p", "paths", 2, "read/write paths") }

  describe ".matches" do
    it "matches args against multiple options" do
      options = [force, paths]
      args = %w(-f -p /source /destination)

      matches = described_class.matches(options, args)

      expect(matches[force].size).to eq(1)
      expect(matches[paths].size).to eq(1)

      expect(matches[force].map(&:args)).to eq [[]]
      expect(matches[paths].map(&:args)).to eq [%w(/source /destination)]
    end

    it "can match an option multiple times" do
      args = %w(-f -f -p /a /b -p /c /d)

      matches = described_class.matches([force, paths], args)

      expect(matches[force].map(&:args)).to eq [[], []]
      expect(matches[paths].map(&:args)).to eq [%w(/a /b), %w(/c /d)]
    end

    it "can match options in any order" do
      args = %w(-p /a /b -f -p /c /d -f)

      matches = described_class.matches([force, paths], args)

      expect(matches[force].map(&:args)).to eq [[], []]
      expect(matches[paths].map(&:args)).to eq [%w(/a /b), %w(/c /d)]
    end

    it "does not mutate args" do
      args = %w(-f -p /source /destination)

      matches = described_class.matches([force, paths], args)
      expect(args).to eq(%w(-f -p /source /destination))
    end
  end

  describe "#match" do
    it "matches on the short or long name" do
      expect(force.match(%w(-f))).to be_a(described_class::Match)
      expect(force.match(%w(--f))).to be_a(described_class::Match)
      expect(force.match(%w(-force))).to be_a(described_class::Match)
      expect(force.match(%w(--force))).to be_a(described_class::Match)
    end

    it "does not match on other names" do
      expect(force.match(%w(-g))).to be_nil
      expect(force.match(%w(-ff))).to be_nil
      expect(force.match(%w(f))).to be_nil
      expect(force.match(%w(-g -f))).to be_nil
    end

    it "keeps a reference to the option on the match" do
      match = force.match(%w(-f))
      expect(match.option).to eq(force)
    end

    it "consumes the option on a match" do
      args = %w(-f other things)

      force.match(args)
      expect(args).to eq(%w(other things))
    end

    it "consumes the number of args of the option's arity" do
      args = %w(-p /source /destination other things)

      paths.match(args)
      expect(args).to eq(%w(other things))
    end

    it "sets the consumed arguments on the match" do
      args = %w(-p /source /destination other things)

      match = paths.match(args)
      expect(match.args).to eq(%w(/source /destination))
    end
  end
end
