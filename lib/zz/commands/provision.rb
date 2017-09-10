module ZZ
  module Provision
    CHEF_INSTALLER = "https://www.opscode.com/chef/install.sh"
    CHEF_CONFIG = ZZ::Path.chef_config

    class << self
      def execute(args)
        install_chef unless chef_installed?
        run_chef
      end

      def install_chef
        Exec.execute("curl -sL #{CHEF_INSTALLER} | sudo bash")
      end

      def chef_installed?
        Exec.execute("which chef-solo")
      end

      def run_chef
        Exec.execute("chef-solo --config #{CHEF_CONFIG}")
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
