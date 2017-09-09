RSpec.describe ZZ do
  it "says hello" do
    expect { ZZ.execute(1) }.to output("Hello, world!\n").to_stdout
  end
end
