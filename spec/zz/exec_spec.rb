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
      expect(result).to eq("foo\n")
    end
  end

  describe ".install_chef" do
    it "curls the chef installer and runs it as root" do
      expect(subject).to receive(:execute)
        .with("curl -sL #{ZZ::Path.chef_installer} | sudo bash")

      subject.install_chef
    end
  end

  describe ".chef_installed?" do
    it "returns whether chef-solo is installed" do
      bool = double(:bool)

      expect(subject).to receive(:execute)
        .with("which chef-solo").and_return(bool)

      expect(subject.chef_installed?).to eq(bool)
    end
  end

  describe ".run_chef" do
    it "runs chef with the path to its config" do
      expect(subject).to receive(:execute)
        .with("chef-solo --config #{ZZ::Path.chef_config}")

      subject.run_chef
    end
  end

  describe ".grant_permissions" do
    it "grants the permission to run sudo without a password" do
      expect(subject).to receive(:execute)
        .with("echo 'foo ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/foo")

      subject.grant_permissions("foo")
    end

    it "defaults to the current user" do
      allow(ENV).to receive(:[]).and_return("bar")

      expect(subject).to receive(:execute)
        .with("echo 'bar ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/bar")

      subject.grant_permissions
    end
  end

  describe ".revoke_permissions" do
    it "revokes the permission to run sudo without a password" do
      expect(subject).to receive(:execute).with("sudo rm -f /etc/sudoers.d/foo")
      subject.revoke_permissions("foo")
    end

    it "defaults to the current user" do
      allow(ENV).to receive(:[]).and_return("bar")

      expect(subject).to receive(:execute).with("sudo rm -f /etc/sudoers.d/bar")
      subject.revoke_permissions
    end
  end
end
