RSpec.describe ZZ::Template do
  let(:tmp_dir) { Dir.mktmpdir }
  before { allow(Dir).to receive(:pwd).and_return(tmp_dir) }

  it "provides useful information about itself" do
    expect(subject.name).to eq("template")
    expect(subject.summary).to eq("creates a project template")
    expect(subject.description).to match(/in the target language/)
  end

  def expect_prompt(responses:)
    expect($stdin).to receive(:gets).at_least(:once)
      .and_return(*responses)
  end

  it "prompts for the type of template" do
    expect_prompt(responses: ["ruby"])

    expect { subject.execute([]) }
      .to output(/Which type?/).to_stdout
  end

  it "prompts for the project name" do
    expect_prompt(responses: ["ruby", "my_project"])

    expect { subject.execute([]) }
      .to output(/Project name:/).to_stdout
  end

  it "copies the template directory to the project name" do
    expect_prompt(responses: ["ruby", "my_project"])
    project_directory = "#{tmp_dir}/my_project"

    expect { subject.execute([]) }.to output.to_stdout
      .and change { File.exist?(project_directory) }
      .from(false)
      .to(true)

    expect(File.exist?("#{project_directory}/Gemfile")).to eq(true)
  end

  it "sets the name of the project in the copied files" do
    expect_prompt(responses: ["ruby", "my_project"])
    project_directory = "#{tmp_dir}/my_project"

    expect { subject.execute([]) }.to output.to_stdout

    readme = File.read("#{project_directory}/README.md")
    expect(readme).to include("MyProject")

    spec_helper = File.read("#{project_directory}/spec/spec_helper.rb")
    expect(spec_helper).to include('require "my_project"')

    expect(File.exist?("#{project_directory}/lib/my_project.rb")).to eq(true)
  end

  it "sets the copyright owner" do
    expect_prompt(responses: ["ruby", "my_project"])

    expect { subject.execute([]) }.to output.to_stdout

    project_directory = "#{tmp_dir}/my_project"
    license = File.read("#{project_directory}/LICENSE")

    expect(license).to match(/20.. Chris Patuzzo <chris@patuzzo.co.uk>/)
  end

  it "runs the template's setup script" do
    expect_prompt(responses: ["ruby", "my_project"])
    project_directory = "#{tmp_dir}/my_project"

    expect(ZZ::Exec).to receive(:setup_template)
    expect { subject.execute([]) }.to output.to_stdout
  end

  describe "error handling" do
    it "raises an error if the type is unknown" do
      expect_prompt(responses: ["unknown"])

      expect { subject.execute([]) }.to output.to_stdout
        .and raise_error(/unknown template type/i)
    end

    it "raises an error if the project name is invalid" do
      expect_prompt(responses: ["ruby", "invalid name"])

      expect { subject.execute([]) }.to output.to_stdout
        .and raise_error(/invalid project name/i)
    end

    it "raises an error if something exists by that name" do
      FileUtils.touch("#{Dir.pwd}/already_exists")
      expect_prompt(responses: ["ruby", "already_exists"])

      expect { subject.execute([]) }.to output.to_stdout
        .and raise_error(/already exists by that name/i)
    end
  end

  describe "options" do
    it "can set the template type" do
      expect_prompt(responses: ["my_project"])

      expect { subject.execute(%w(--type ruby)) }
        .not_to output(/Which type?/).to_stdout
    end

    it "can set the project name" do
      expect_prompt(responses: ["ruby"])

      expect { subject.execute(%w(--name my_project)) }
        .not_to output(/Project name:/).to_stdout
    end

    it "can set the copyright owner" do
      expect_prompt(responses: ["ruby", "my_project"])

      expect { subject.execute(["--copyright", "Foo <foo@bar.com>"]) }
        .to output.to_stdout

      project_directory = "#{tmp_dir}/my_project"
      license = File.read("#{project_directory}/LICENSE")

      expect(license).to match(/20.. Foo <foo@bar.com>/)
    end

    it "can list available templates" do
      expect { subject.execute(%w(--list)) }
        .to output(/available template types/i).to_stdout
    end
  end
end
