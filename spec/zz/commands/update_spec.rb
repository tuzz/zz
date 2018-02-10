RSpec.describe ZZ::Update do
  it "provides useful information about itself" do
    expect(subject.name).to eq("update")
    expect(subject.summary).to eq("pulls changes to zz from github")
    expect(subject.description).to match(/zz will prompt the user/)
  end
end
