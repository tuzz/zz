module ZZ
  module Exec
    class << self
      def execute(command)
        system(command)
      end

      def capture(command)
        `#{command}`.strip
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

      def chrome_installed?
        execute("brew cask list | grep google-chrome")
      end

      def install_chrome
        execute("brew cask install google-chrome")
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
        fingerprint = capture("gpg --list-keys | awk 'NR==4'")
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

      def iterm_installed?
        execute("brew cask list | grep iterm2")
      end

      def install_iterm
        execute("brew cask install iterm2")
      end

      def iterm_config_dir_set?
        Pref.iterm_config_enabled &&
          Pref.iterm_config_directory == Path.iterm_directory
      end

      def set_iterm_config_dir
        Pref.iterm_config_enabled = true
        Pref.iterm_config_directory = Path.iterm_directory
      end

      def vim_plugins_installed?
        capture("ls #{Path.vim_bundle_directory} | wc -l").to_i > 1
      end

      def install_vim_plugins
        execute("vim +PluginInstall +qall")
      end

      def fast_key_repeat?
        Pref.key_repeat == 2
      end

      def set_fast_key_repeat
        Pref.key_repeat = 2
      end

      def short_key_delay?
        Pref.key_delay == 15
      end

      def set_short_key_delay
        Pref.key_delay = 15
      end

      def latest_ruby_installed?
        capture("rbenv versions").include?(latest_ruby)
      end

      def install_latest_ruby
        execute("rbenv install #{latest_ruby}")
      end

      def latest_ruby
        capture("rbenv install -l | grep -v '[a-z]' | tail -1")
      end

      def global_ruby_set?
        capture("rbenv global") == latest_ruby
      end

      def set_global_ruby
        execute("rbenv global #{latest_ruby}")
      end

      def latest_node_installed?
        capture("nodenv versions").include?(latest_node)
      end

      def install_latest_node
        execute("nodenv install #{latest_node}")
      end

      def latest_node
        capture("nodenv install -l | grep -v '[a-z]' | tail -1")
      end

      def global_node_set?
        capture("nodenv global") == latest_node
      end

      def set_global_node
        execute("nodenv global #{latest_node}")
      end
    end
  end
end
