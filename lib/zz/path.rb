module ZZ
  module Path
    class << self
      def to(path)
        File.expand_path("../../#{path}", __dir__)
      end

      def root
        to(nil)
      end

      def tmp
       to("tmp")
      end

      def chef_cookbooks
        to("chef")
      end

      def chef_run_list
        to("chef/node.json")
      end

      def chef_cache
        tmp
      end

      def chef_config
        to("chef/config.rb")
      end

      def chef_installer
        "https://www.opscode.com/chef/install.sh"
      end

      def homebrew_remote_installer
        "https://raw.githubusercontent.com/Homebrew/install/master/install"
      end

      def homebrew_local_installer
        to("tmp/hombrew_installer")
      end

      def dropbox_config
        File.expand_path("~/.dropbox/info.json")
      end

      def dropbox_app
        "/Applications/Dropbox.app"
      end

      def ssh_key
        File.expand_path("~/Dropbox/Reference/Keys/id_rsa")
      end

      def gpg_key
        File.expand_path("~/Dropbox/Reference/Keys/private.key")
      end
    end
  end
end
