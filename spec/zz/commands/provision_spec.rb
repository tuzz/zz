RSpec.describe ZZ::Provision do
  it "provides useful information about itself" do
    expect(subject.name).to eq("provision")
    expect(subject.summary).to eq("sets up a machine for development")
    expect(subject.description).to match(/fresh install of macOS/)
  end

  it "installs chef if it isn't already installed" do
    allow(ZZ::Exec).to receive(:chef_installed?).and_return(false)
    expect(ZZ::Exec).to receive(:install_chef)

    subject.execute([])
  end

  it "does not install chef if it's already installed" do
    allow(ZZ::Exec).to receive(:chef_installed?).and_return(true)
    expect(ZZ::Exec).not_to receive(:install_chef)

    subject.execute([])
  end

  it "grants permissions, then runs chef, then revokes permissions" do
    expect(ZZ::Exec).to receive(:grant_permissions).ordered
    expect(ZZ::Exec).to receive(:run_chef).ordered
    expect(ZZ::Exec).to receive(:revoke_permissions).ordered

    subject.execute([])
  end

  it "ensures permissions are revoked if something goes wrong" do
    allow(ZZ::Exec).to receive(:run_chef).and_raise("test")
    expect(ZZ::Exec).to receive(:revoke_permissions)

    expect { subject.execute([]) }.to raise_error("test")
  end

  describe "options" do
    before do
      allow(ZZ::Exec).to receive(:chef_installed?).and_return(true)
      allow(ZZ::Exec).to receive(:grant_permissions)
      allow(ZZ::Exec).to receive(:revoke_permissions)
    end

    it "can list available recipes" do
      expect(ZZ::Exec).not_to receive(:run_chef)

      expect { subject.execute(%w(--list)) }
        .to output(/slack\nssh\ntools/).to_stdout
    end

    it "can run a subset of recipes" do
      expect(ZZ::Exec).to receive(:run_chef).with("foo,bar")
      subject.execute(%w(--only foo,bar))
    end

    it "auto-completes the 'only' option" do
      complete = subject.options.detect { |o| o.long == "only" }.complete

      expect(complete.call([""])).to include("git", "ruby", "vim")
      expect(complete.call(["ru"])).to eq ["ruby", "rust"]
      expect(complete.call(["VI"])).to eq ["vim", "virtualbox"]

      expect(complete.call(["x"])).to eq []
      expect(complete.call(["ruby"])).to include("git", "ruby", "vim")

      # Although this exact-matches, there are other options:
      expect(complete.call(["Chrome"])).to eq ["chrome", "chromedriver"]

      expect(complete.call(["vim,ru"])).to eq ["vim,ruby", "vim,rust"]
      expect(complete.call(["vim,ruby"])).to include("git", "ruby", "vim")
      expect(complete.call(["vim,ruby,Chrome"])).to eq [
        "vim,ruby,chrome",
        "vim,ruby,chromedriver",
      ]

      expect(complete.call(["vim,ruby,x,y,Ch"])).to eq [
        "vim,ruby,x,y,chrome",
        "vim,ruby,x,y,chromedriver",
      ]
    end

    it "can print a recipe to stdout" do
      expect(ZZ::Exec).not_to receive(:run_chef)

      expect { subject.execute(%w(--print vim)) }
        .to output(/package "vim"/).to_stdout
    end

    it "can open a provisioning recipe for editing" do
      expect(ZZ::Exec).not_to receive(:run_chef)

      expect(ZZ::Exec).to receive(:edit) do |file|
        expect(file).to end_with("/.zz/chef/vim/recipes/default.rb")
      end

      subject.execute(%w(--edit vim))
    end

    context "when the recipe to edit doesn't exist" do
      it "raises an error" do
        expect { subject.execute(%w(--edit missing)) }
          .to raise_error(/No such file or directory/)
      end
    end

    it "auto-completes the 'print' and 'edit' options" do
      %w(print edit).each do |name|
        complete = subject.options.detect { |o| o.long == name }.complete

        expect(complete.call([""])).to include("git", "ruby", "vim")
        expect(complete.call(["ru"])).to eq ["ruby", "rust"]
        expect(complete.call(["VI"])).to eq ["vim", "virtualbox"]

        expect(complete.call(["x"])).to eq []
        expect(complete.call(["vim"])).to eq []
        expect(complete.call(["vim,ru"])).to eq []
      end
    end
  end
end
