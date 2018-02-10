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

      def dropbox_config
        File.expand_path("~/.dropbox/info.json")
      end

      def dropbox_app
        "/Applications/Dropbox.app"
      end

      def screenflow_config
        to("chef/screenflow/files/config.xml")
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

      def gpg_agent_config
        File.expand_path("~/.gnupg/gpg-agent.conf")
      end

      def public_gpg_key
        to("chef/gpg/files/public_gpg_key")
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

      def iterm_directory
        to("chef/iterm/files")
      end

      def vim_bundle_directory
        File.expand_path("~/.vim/bundle")
      end

      def vim_config
        File.expand_path("~/.vimrc")
      end

      def vundle_remote_repo
        "https://github.com/VundleVim/Vundle.vim"
      end

      def vundle_local_repo
        File.expand_path("~/.vim/bundle/Vundle.vim")
      end

      def gem_config
        File.expand_path("~/.gemrc")
      end

      def user_profile
        File.expand_path("~/.profile")
      end

      def hushlogin
        File.expand_path("~/.hushlogin")
      end

      def code
        File.expand_path("~/code")
      end

      def govuk_puppet
        File.expand_path("~/code/govuk-puppet")
      end

      def dev_vm
        File.expand_path("~/code/govuk-puppet/development-vm")
      end

      def dev_vm_cache
        File.expand_path("~/code/govuk-puppet/development-vm/.vagrant")
      end

      def minidlna_directory
        File.expand_path("~/.config/minidlna")
      end

      def minidlna_config
        File.expand_path("~/.config/minidlna/minidlna.conf")
      end

      def minidlna_media
        "/Volumes/hdd"
      end
    end
  end
end
