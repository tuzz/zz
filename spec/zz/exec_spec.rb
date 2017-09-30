RSpec.describe ZZ::Exec do
  describe ".execute" do
    before do
      allow(subject).to receive(:execute).and_call_original
    end

    it "executes the command in a subprocess" do
      result = subject.execute("touch foo")

      expect(result).to eq(true)
      expect(File.exists?("foo"))

      FileUtils.rm_f("foo")
    end
  end

  describe ".capture" do
    before do
      allow(subject).to receive(:capture).and_call_original
    end

    it "executes the command and returns its output" do
      result = subject.capture("echo foo")
      expect(result).to eq("foo")
    end
  end

  describe ".edit" do
    it "opens the path in the default editor, falling back to vi" do
      expect(subject).to receive(:execute).with("${EDITOR:-vi} foo")

      subject.edit("foo")
    end
  end
end
