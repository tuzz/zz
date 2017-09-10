module ZZ
  module Provision
    class << self
      def execute(args)
        Exec.install_chef unless Exec.chef_installed?
        Exec.run_chef
      end

      def name
        "provision"
      end

      def summary
        "sets up a machine for development"
      end

      def description
        [
          "This command is designed to run on a fresh install of macOS.",
          "It configures system preferences and installs a lot of things,",
          "such as programming languages, web browsers, the best text editor",
          "and other development tools."
        ].join("\n  ")
      end

      def options
        []
      end
    end
  end
end
