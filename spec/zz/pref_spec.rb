RSpec.describe ZZ::Pref do
  describe ".read" do
    it "reads the value from the 'defaults' system preference command" do
      allow(ZZ::Exec).to receive(:capture)
        .with("defaults read 'com.example' SomeKey 2>&1")
        .and_return("some value")

      result = subject.read("com.example", "SomeKey")
      expect(result).to eq("some value")
    end

    it "strips whitespace" do
      allow(ZZ::Exec).to receive(:capture).and_return("\n\n some value\n\n ")

      result = subject.read("com.example", "SomeKey")
      expect(result).to eq("some value")
    end

    it "returns nil if the preference doesn't exist" do
      allow(ZZ::Exec).to receive(:capture).and_return("does not exist")

      result = subject.read("com.example", "Missing")
      expect(result).to be_nil
    end
  end

  describe ".write" do
    it "writes the value using the 'defaults' system preference command" do
      expect(ZZ::Exec).to receive(:execute)
        .with("defaults write 'com.example' SomeKey -some_type 'some value'")

      subject.write("com.example", "SomeKey", "some_type", "some value")
    end
  end
end
