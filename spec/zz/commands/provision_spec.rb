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

  pending "--list option the prints the run_list"
end
