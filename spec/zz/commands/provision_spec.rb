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

  it "runs chef" do
    expect(ZZ::Exec).to receive(:run_chef)
    subject.execute([])
  end

  pending "--list option the prints the run_list"
end
