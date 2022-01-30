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

      def mysides_remote_package
        "https://github.com/mosen/mysides/releases/download/v1.0.1/mysides-1.0.1.pkg"
      end

      def mysides_local_package
        to("tmp/mysides.pkg")
      end

      def pdftk_remote_package
        "https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg"
      end

      def pdftk_local_package
        to("tmp/pdftk.pkg")
      end

      def dropbox_config
        File.expand_path("~/.dropbox/info.json")
      end

      def dropbox_app
        "/Applications/Dropbox.app"
      end

      def docker_app
        "/Applications/Docker.app"
      end

      def screenflow_config
        to("chef/screenflow/files/config.xml")
      end

      def ffmpeg_recipe
        "/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/ffmpeg.rb"
      end

      def transcode
        "/usr/local/bin/transcode"
      end

      def gpg_directory
        File.expand_path("~/.gnupg")
      end

      def gpg_config
        File.expand_path("~/.gnupg/gpg.conf")
      end

      def gpg_scdaemon
        File.expand_path("~/.gnupg/scdaemon.conf")
      end

      def gpg_reset
        File.expand_path("/usr/local/bin/gpg-reset")
      end

      def gpg_agent_config
        File.expand_path("~/.gnupg/gpg-agent.conf")
      end

      def public_gpg_key
        to("chef/gpg/files/public_gpg_key")
      end

      def scan
        File.expand_path("/usr/local/bin/scan")
      end

      def ssh_directory
        File.expand_path("~/.ssh")
      end

      def ssh_config
        File.expand_path("~/.ssh/config")
      end

      def authorized_keys
        File.expand_path("~/.ssh/authorized_keys")
      end

      def chef_sshd_config
        to("chef/ssh/files/sshd_config")
      end

      def sshd_config
        "/etc/ssh/sshd_config"
      end

      def git_config
        File.expand_path("~/.gitconfig")
      end

      def git_ignore
        File.expand_path("~/.gitignore")
      end

      def git_branch
        File.expand_path("/usr/local/bin/git_branch")
      end

      def vpn
        File.expand_path("/usr/local/bin/vpn")
      end

      def iterm_directory
        to("chef/iterm/files")
      end

      def vim_bundle_directory
        File.expand_path("~/.vim/bundle")
      end

      def vim_autoload_directory
        File.expand_path("~/.vim/autoload")
      end

      def vim_syntax_directory
        File.expand_path("~/.vim/after/syntax")
      end

      def vim_config
        File.expand_path("~/.vimrc")
      end

      def vim_plug_remote
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
      end

      def vim_plug_local
        File.expand_path("~/.vim/autoload/plug.vim")
      end

      def gem_config
        File.expand_path("~/.gemrc")
      end

      def user_profile
        File.expand_path("~/.zshrc")
      end

      def hushlogin
        File.expand_path("~/.hushlogin")
      end

      def code
        File.expand_path("~/code")
      end

      def minidlna_directory
        File.expand_path("~/.config/minidlna")
      end

      def minidlna_config
        File.expand_path("~/.config/minidlna/minidlna.conf")
      end

      def minidlna_reindex
        "/usr/local/bin/reindex"
      end

      def minidlna_media
        "/Volumes/hdd"
      end

      def templates
        to("templates")
      end

      def edit
        "/usr/local/bin/edit"
      end

      def cargo
        File.expand_path("~/.cargo")
      end

      def cargo_bin
        File.expand_path("~/.cargo/bin")
      end

      def zz_completion
        "/usr/local/bin/zz-completion.bash"
      end

      def secrets
        File.expand_path("~/Dropbox/Secrets")
      end
    end
  end
end
