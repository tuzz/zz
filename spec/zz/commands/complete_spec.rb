RSpec.describe ZZ::Complete do
  it "provides useful information about itself" do
    expect(subject.name).to eq("complete")
    expect(subject.summary).to eq("autocompletes a zz command")
    expect(subject.description).to match(/provides autocompletion support for zz/)
  end

  it "prints all commands when no command has been specified" do
    expect { subject.execute(["zz"]) }
      .to output("complete debug provision template update").to_stdout
  end

  it "prints commands that match the 1th argument" do
    expect { subject.execute(["zz", "p"]) }.to output("provision").to_stdout

    expect { subject.execute(["zz", "d"]) }.to output("debug").to_stdout
    expect { subject.execute(["zz", "deb"]) }.to output("debug").to_stdout
  end

  it "prints nothing if the 1th argument doesn't match" do
    expect { subject.execute(["zz", "x"]) }.to output("").to_stdout
  end

  it "prints the command's options on an exact match of a command" do
    expect { subject.execute(["zz", "provision"]) }
      .to output("--only --print --edit --list").to_stdout
  end

  it "prints the command's options that match the last argument" do
    expect { subject.execute(["zz", "provision", "--l"]) }.to output("--list").to_stdout

    expect { subject.execute(["zz", "provision", "--ed"]) }.to output("--edit").to_stdout

    expect { subject.execute(["zz", "provision", "a", "b", "c", "--ed"]) }
      .to output("--edit").to_stdout
  end

  context "when there is an exact match of an option" do
    it "prints all options if the option takes no arguments" do
      expect { subject.execute(["zz", "provision", "--list"]) }
        .to output("--only --print --edit --list").to_stdout
    end

    it "prints nothing if the option takes arguments" do
      expect { subject.execute(["zz", "provision", "--only"]) }
        .to output("").to_stdout
    end

    pending "hand over to option for autocompletion"
  end
end
