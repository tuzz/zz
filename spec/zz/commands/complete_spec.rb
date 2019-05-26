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
      expect { subject.execute(["zz", "template", "--list"]) }
        .to output("--type --name --copyright --list").to_stdout
    end

    it "prints nothing if the option takes arguments" do
      expect { subject.execute(["zz", "template", "--name"]) }
        .to output("").to_stdout
    end
  end

  context "when the option has a completion proc" do
    it "prints the result of calling the proc" do
      expect { subject.execute(["zz", "template", "--type"]) }
        .to output("rust cpp ruby").to_stdout
    end

    it "passes args to the proc so it can filter the list of completions" do
      expect { subject.execute(["zz", "template", "--type", "ru"]) }
        .to output("rust ruby").to_stdout
    end

    it "prints nothing if the argument doesn't match" do
      expect { subject.execute(["zz", "template", "--type", "x"]) }
        .to output("").to_stdout
    end

    it "prints nothing if the option does not have a completion proc" do
      expect { subject.execute(["zz", "template", "--name"]) }
        .to output("").to_stdout
    end

    it "can handle the option in an earlier position" do
      expect { subject.execute(["zz", "template", "--type", "x", "x", "ru"]) }
        .to output("rust ruby").to_stdout
    end

    it "ignores arguments in earlier positions that look like options" do
      expect { subject.execute(["zz", "template", "--type", "x", "--x", "ru"]) }
        .to output("rust ruby").to_stdout
    end

    it "ignores earlier options when determining the auto-completion list" do
      expect { subject.execute(["zz", "template", "--type", "ru", "--type"]) }
        .to output("rust cpp ruby").to_stdout
    end
  end
end
