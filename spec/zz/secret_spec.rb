RSpec.describe ZZ::Secret do
  describe ".read" do
    before do
      allow(ZZ::Exec).to receive(:capture).and_call_original
    end

    it 'reads secrets' do
      username = subject.read(".test", "username")
      expect(username).to eq("tuzz@example.com")

      password = subject.read(".test", "password")
      expect(password).to eq("Password123")
    end

    it "errors if the secret doesn't exist" do
      expect { subject.read(".test", "missing") }
        .to raise_error(SecretNotFoundError, %r{Secrets/.test/missing.gpg})
    end
  end

  describe ".path" do
    it "returns the path to the secret" do
      path = subject.path(".test", "foo", "bar")
      expect(path).to eq("/Users/tuzz/Dropbox/Secrets/.test/foo/bar.gpg")
    end
  end
end
