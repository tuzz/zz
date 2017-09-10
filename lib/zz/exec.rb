module ZZ
  module Exec
    class << self
      def execute(command)
        system(command)
      end

      def capture(command)
        `#{command}`
      end

      def install_chef
        execute("curl -sL #{Path.chef_installer} | sudo bash")
      end

      def chef_installed?
        execute("which chef-solo")
      end

      def run_chef
        execute("chef-solo --config #{Path.chef_config}")
      end
    end
  end
end
