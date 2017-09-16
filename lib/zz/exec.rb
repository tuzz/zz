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

      def grant_permissions(u = ENV["USER"])
        execute(
          "echo '#{u} ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/#{u}"
        )
      end

      def revoke_permissions(u = ENV["USER"])
        execute("sudo rm -f /etc/sudoers.d/#{u}")
      end

      def homebrew_installed?
        execute("which brew")
      end

      def tapped_cask?
        execute("brew tap | grep caskroom/cask")
      end

      def tap_cask
        execute("brew tap caskroom/cask")
      end

      def dropbox_installed?
        execute("brew cask list | grep dropbox")
      end

      def install_dropbox
        execute("brew cask install dropbox")
      end

      def logged_into_dropbox?
        execute("ls #{Path.dropbox_config} 2> /dev/null")
      end

      def open_dropbox
        execute("open #{Path.dropbox_app}")
      end

      def dropbox_synced?
        execute("test -s #{Path.ssh_backup} && test -s #{Path.gpg_backup}")
      end

      def gpg_key_imported?
        !capture("gpg --list-secret-keys").empty?
      end

      def import_private_gpg_key
        execute("gpg --import #{Path.gpg_backup}")
      end

      def import_public_gpg_key
        execute("gpg --import #{Path.public_gpg_key}")
      end

      def gpg_key_trusted?
        capture("gpg --list-keys").include?("ultimate")
      end

      def trust_gpg_key
        fingerprint = capture("gpg --list-keys | awk 'NR==4'").strip
        edit_key = "gpg --edit-key #{fingerprint} trust quit"
        user_input = '\"5\ry\r\"'

        system(%{expect -c "spawn #{edit_key}; send #{user_input}; expect eof"})
      end

      def git_repo_initialized?
        system("ls ~/.zz/.git")
      end

      def initialize_git_repo
        system <<-SH
          pushd ~/.zz
          git init
          git remote add origin git@github.com:tuzz/zz
          git fetch
          git reset --hard origin/master
          popd
        SH
      end
    end
  end
end
