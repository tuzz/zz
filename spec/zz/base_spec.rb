RSpec.describe ZZ do
  it "prints usage if a recognised command isn't the first argument" do
    expect { subject.execute([]) }.to output(/Usage:/).to_stdout
    expect { subject.execute(%w(-h)) }.to output(/Usage:/).to_stdout
    expect { subject.execute(%w(--help)) }.to output(/Usage:/).to_stdout
    expect { subject.execute(%w(--anything)) }.to  output(/Usage:/).to_stdout
    expect { subject.execute(%w(unrecognised)) }.to output(/Usage:/).to_stdout
    expect { subject.execute(%w(-a provision)) }.to output(/Usage:/).to_stdout
  end

  it "passes the remaining args to the command" do
    expect(subject::Provision).to receive(:execute).with(%w(foo -a bar -b))
    subject.execute(%w(provision foo -a bar -b))
  end
end
