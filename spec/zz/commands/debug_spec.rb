RSpec.describe ZZ::Debug do
  it "provides useful information about itself" do
    expect(subject.name).to eq("debug")
    expect(subject.summary).to eq("runs an introspective debugger for zz")
    expect(subject.description).to match(/starts a pry session/)
  end

  it "runs pry" do
    expect(ZZ).to receive(:pry)
    subject.execute([])
  end

  it "falls back to irb if pry is unavailable" do
    allow(subject).to receive(:run_pry).and_raise(LoadError)

    expect(IRB).to receive(:start)
    subject.execute([])
  end
end
