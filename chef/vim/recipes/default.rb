package "vim"

directory "create vim bundle directory" do
  path ZZ::Path.vim_bundle_directory
  recursive true
end

cookbook_file "vim_config" do
  source "vim_config"
  path ZZ::Path.vim_config
end

git "clone Vundle" do
  repository ZZ::Path.vundle_remote_repo
  destination ZZ::Path.vundle_local_repo
end

ruby_block "install vim plugins" do
  not_if { ZZ::Exec.vim_plugins_installed? }
  block { ZZ::Exec.install_vim_plugins }
end
