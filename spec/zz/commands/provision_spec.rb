RSpec.describe ZZ::Provision do
  it "provides useful information about itself" do
    expect(subject.name).to eq("provision")
    expect(subject.summary).to eq("sets up a machine for development")
    expect(subject.description).to match(/fresh install of macOS/)
  end

  it "installs chef if it isn't already installed" do
    allow(ZZ::Exec).to receive(:execute)
      .with("which chef-solo").and_return(false)

    expect(ZZ::Exec).to receive(:execute)
      .with("curl -sL https://www.opscode.com/chef/install.sh | sudo bash")

    allow(ZZ::Exec).to receive(:execute)

    subject.execute([])
  end

  it "does not install chef if it's already installed" do
    allow(ZZ::Exec).to receive(:execute)
      .with("which chef-solo").and_return(true)

    expect(ZZ::Exec).not_to receive(:execute)
      .with("curl -sL #{subject::CHEF_INSTALLER} | sudo bash")

    subject.execute([])
  end

  it "runs chef" do
    allow(ZZ::Exec).to receive(:execute)

    expect(ZZ::Exec).to receive(:execute)
      .with("chef-solo --config #{subject::CHEF_CONFIG}")

    subject.execute([])
  end

  pending "--list option the prints the run_list"
end
