ruby_block "install iterm" do
  not_if { ZZ::Exec.cask_installed?("iterm2") }
  block { ZZ::Exec.install_cask("iterm2") }
end

ruby_block "set iterm config dir" do
  not_if { ZZ::Exec.iterm_config_dir_set? }
  block { ZZ::Exec.set_iterm_config_dir }
end
