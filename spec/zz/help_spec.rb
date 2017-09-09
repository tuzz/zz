RSpec.describe ZZ::Help do
  let(:commands) do
    [
      double(
        :command,
        name: "foo",
        summary: "foo summary",
        description: "foo description",
        options: [
          double(
            :option,
            short: "v",
            long: "verbose",
            summary: "print verbose output"
          ),
          double(
            :option,
            short: "s",
            long: "silent",
            summary: "supress all output",
          ),
        ]
      ),
      double(
        :command,
        name: "bar",
        summary: "bar summary",
        description: "bar description",
        options: [],
      ),
    ]
  end

  describe ".usage" do
    it "prints usage including commands and options" do
      result = subject.usage(commands)

      expect(result.split("\n")).to include(
        "The tuzz automation tool",

        "Usage: zz <command> [options]",

        "Commands:",
        "  foo: foo summary",
        "  bar: bar summary",

        "foo:",
        "  foo description",

        "  -v, --verbose, print verbose output",
        "  -s, --silent, supress all output",

        "bar:",
        "  bar description",
      )
    end
  end
end
