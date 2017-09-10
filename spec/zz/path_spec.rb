RSpec.describe ZZ::Path do
  let(:root) { File.expand_path("../..", __dir__) }

  describe ".to" do
    it "returns an absolute path from ZZ's root" do
      result = subject.to("foo/bar")
      expect(result).to eq("#{root}/foo/bar")
    end

    it "ignores leading slashes" do
      result = subject.to("/foo/bar")
      expect(result).to eq("#{root}/foo/bar")
    end

    it "collapses relative paths" do
      result = subject.to("foo/../foo/bar/../bar")
      expect(result).to eq("#{root}/foo/bar")
    end
  end

  specify { expect(subject.root).to eq(root) }
end
