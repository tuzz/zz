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

      def service_started?(name)
        execute("brew services list | grep #{name} | grep started > /dev/null")
      end

      def start_service(name)
        execute("brew services start #{name}")
      end

      def mysides_installed?
        execute("which mysides 2> /dev/null")
      end

      def install_mysides
        execute("sudo installer -pkg #{Path.mysides_local_package} -target /")
      end

      def pdftk_installed?
        execute("which pdftk 2> /dev/null")
      end

      def install_pdftk
        execute("sudo installer -pkg #{Path.pdftk_local_package} -target /")
      end

      def sidebar_items
        capture("mysides list | awk '{ print $1 }'").split
      end

      def add_sidebar_item(name, path)
        system("mysides add #{name} #{path}")
      end

      def remove_sidebar_item(name)
        loop { break unless system("mysides remove #{name}") }
      end

      def whoami
        capture("whoami").strip
      end

      def logged_into_dropbox?
        execute("ls #{Path.dropbox_config} 2> /dev/null")
      end

      def open_dropbox
        execute("open #{Path.dropbox_app}")
      end

      def open_docker
        execute("open #{Path.docker_app}")
      end

      def cask_installed?(name)
        execute("brew cask list | grep #{name}")
      end

      def install_cask(name)
        execute("brew cask install #{name}")
      end

      def public_gpg_key_imported?
        !capture("gpg --list-keys").empty?
      end

      def import_public_gpg_key
        execute("gpg --import #{Path.public_gpg_key}")
      end

      def gpg_key_trusted?
        capture("gpg --list-keys").include?("ultimate")
      end

      def trust_gpg_key
        line = capture("gpg --list-keys | grep fingerprint")
        fingerprint = line.split("=").last.gsub(/\s/, "")

        edit_key = "gpg --edit-key #{fingerprint} trust quit"
        user_input = '\"5\ry\r\"'

        execute(%{expect -c "spawn #{edit_key}; send #{user_input}; expect eof"})
      end

      def zz_repo_initialized?
        zz_git_exec("git log > /dev/null 2> /dev/null")
      end

      def zz_git_pull
        zz_git_exec("git pull origin master --rebase 2> /dev/null")
      end

      def zz_git_status
        zz_git_exec("git status --short")
      end

      def zz_git_checkout
        zz_git_exec("git checkout . 2> /dev/null")
      end

      def zz_git_reset
        zz_git_exec("git reset --hard origin/master 2> /dev/null")
      end

      def zz_git_init
        zz_git_exec("git init")
      end

      def zz_git_remote_add
        zz_git_exec("git remote add origin git@github.com:tuzz/zz")
      end

      def zz_git_fetch
        zz_git_exec("git fetch")
      end

      def zz_git_exec(command)
        execute("GIT_DIR=~/.zz/.git GIT_WORK_TREE=~/.zz #{command}")
      end

      def gpg_reset
        execute("gpg-reset")
      end

      def ffmpeg_patched?
        File.read(Path.ffmpeg_recipe).include?("libfdk-aac")
      end

      def patch_ffmpeg
        lines = File.read(Path.ffmpeg_recipe).lines
        index = lines.index { |l| l.include?("args =") } + 1

        lines.insert(index, "--enable-nonfree\n")
        lines.insert(index, "--enable-libfdk-aac\n")

        File.write(Path.ffmpeg_recipe, lines.join)
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
        expected = capture("cat #{Path.vim_config} | grep Plug | wc -l").to_i
        actual = capture("ls #{Path.vim_bundle_directory} | wc -l").to_i

        actual == expected
      end

      def install_vim_plugins
        execute("vim +PlugInstall +qall")
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

      def menubar_autohide?
        Pref.menubar_autohide
      end

      def autohide_menubar
        Pref.menubar_autohide = 1
      end

      def screenflow_configured?
        Pref.screenflow_helper_audio
      end

      def configure_screenflow
        Pref.screenflow_helper_audio = 0
        Pref.import_screenflow_config(Path.screenflow_config)
      end

      def cryptomator_dock_icon_hidden?
        Pref.cryptomator_hide_dock_icon
      end

      def hide_cryptomator_dock_icon
        Pref.cryptomator_hide_dock_icon = 1
      end

      def restart_dock
        execute("killall Dock")
      end

      def rustup_nightly
        execute("echo '2\n\nnightly\nn\n1' | rustup-init")
      end

      def cargo_configured?
        execute("ls #{Path.cargo} 2> /dev/null")
      end

      def target_wasm
        execute("rustup target add wasm32-unknown-unknown")
      end

      def wasm_target?
        capture("rustup target list | grep wasm32").include?("installed")
      end

      def install_clippy
        execute("rustup component add clippy --toolchain=nightly")
      end

      def clippy_installed?
        execute("ls #{Path.cargo_bin} | grep cargo-clippy")
      end

      def install_cargo_web
        execute("cargo install cargo-web")
      end

      def cargo_web_installed?
        execute("ls #{Path.cargo_bin} | grep cargo-web")
      end

      def install_cargo_watch
        execute("cargo install cargo-watch")
      end

      def cargo_watch_installed?
        execute("ls #{Path.cargo_bin} | grep cargo-watch")
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

      def node_version_installed?(version)
        capture("nodenv versions").include?(version)
      end

      def install_latest_node
        execute("nodenv install #{latest_node}")
      end

      def install_node_version(version)
        execute("nodenv install #{version}")
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

      def yarn_installed?
        execute("npm list --global --depth 0 | grep yarn")
      end

      def install_yarn
        execute("npm install --global yarn")
      end

      def sshd_config_written?
        execute("sudo cat #{ZZ::Path.sshd_config} | grep 'Protocol 2'")
      end

      def rehash_nodenv
        execute("nodenv rehash")
      end

      def write_sshd_config
        execute("sudo cp #{ZZ::Path.chef_sshd_config} #{ZZ::Path.sshd_config}")
      end

      def restart_sshd
        execute("sudo launchctl stop com.openssh.sshd")
      end

      def setup_template(directory)
        execute("pushd #{directory}; ./__setup.sh; popd")
      end
    end
  end
end
