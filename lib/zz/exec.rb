module ZZ
  module Exec
    class << self
      def execute(command)
        system(command)
      end

      def capture(command)
        `#{command}`.strip
      end

      def edit(path)
        execute("${EDITOR:-vi} #{path}")
      end

      def install_chef
        execute("curl -sL #{Path.chef_installer} | sudo bash")
      end

      def chef_installed?
        execute("which chef-solo")
      end

      def run_chef(scripts)
        run_list = " --override-runlist #{scripts}" if scripts
        execute("chef-solo --config #{Path.chef_config}#{run_list}")
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

      def tapped_drivers?
        execute("brew tap | grep caskroom/drivers")
      end

      def tap_drivers
        execute("brew tap caskroom/drivers")
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

      def cask_installed?(name)
        execute("brew cask list | grep #{name}")
      end

      def install_cask(name)
        execute("brew cask install #{name}")
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

        execute(%{expect -c "spawn #{edit_key}; send #{user_input}; expect eof"})
      end

      def git_repo_initialized?
        execute("ls ~/.zz/.git")
      end

      def initialize_git_repo
        execute <<-SH
          pushd ~/.zz
          git init
          git remote add origin git@github.com:tuzz/zz
          git fetch
          git reset --hard origin/master
          popd
        SH
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
        expected = capture("cat #{Path.vim_config} | grep Plugin | wc -l").to_i
        actual = capture("ls #{Path.vim_bundle_directory} | wc -l").to_i

        actual == expected
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

      def empty_dock?
        Pref.dock_apps == "()" && Pref.dock_others == "()"
      end

      def empty_dock!
        Pref.dock_apps = "()"
        Pref.dock_others = "()"
      end

      def smallest_dock?
        Pref.dock_size == 16
      end

      def set_smallest_dock
        Pref.dock_size = 16
      end

      def dock_right_of_screen?
        Pref.dock_orientation == "right"
      end

      def move_dock_right_of_screen
        Pref.dock_orientation = "right"
      end

      def dock_autohide?
        Pref.dock_autohide
      end

      def autohide_dock
        Pref.dock_autohide = true
      end

      def screenflow_configured?
        Pref.screenflow_helper_audio
      end

      def configure_screenflow
        Pref.screenflow_helper_audio = 0
        Pref.import_screenflow_config(Path.screenflow_config)
      end

      def restart_dock
        execute("killall Dock")
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

      def dev_vm_provisioned?
        execute("ls #{Path.dev_vm_cache} 2> /dev/null")
      end

      def vagrant_dns_installed?
        capture("vagrant plugin list").include?("vagrant-dns")
      end

      def install_vagrant_dns
        execute("vagrant plugin install vagrant-dns")
      end

      def dns_resolver_registered?
        execute("scutil --dns | grep dev.gov.uk")
      end

      def register_dns_resolver
        execute <<-SH
          pushd #{Path.dev_vm}
          vagrant dns --install
          popd
        SH
      end

      def add_ssh_key
        execute("ssh-add")
      end

      def provision_dev_vm
        execute <<-SH
          pushd #{Path.dev_vm}
          vagrant up
          popd
        SH
      end

      def ssh_config_exists?
        execute("ls #{Path.ssh_config} 2> /dev/null")
      end

      def write_ssh_config
        execute <<-SH
          pushd #{Path.dev_vm}
          vagrant ssh-config --host dev > #{Path.ssh_config}
          popd
        SH
      end
    end
  end
end
