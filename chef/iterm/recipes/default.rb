ruby_block "install iterm" do
  not_if { ZZ::Exec.iterm_installed? }
  block { ZZ::Exec.install_iterm }
end

directory "create iterm directory" do
  path ZZ::Path.iterm_directory
end

ruby_block "set iterm config dir" do
  not_if { ZZ::Exec.iterm_config_dir_set? }
  block { ZZ::Exec.set_iterm_config_dir }
end

cookbook_file "configure iterm" do
  source "iterm_config"
  path ZZ::Path.iterm_config
end
