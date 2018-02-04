ruby_block "install dropbox" do
  not_if { ZZ::Exec.cask_installed?("dropbox") }
  block { ZZ::Exec.install_cask("dropbox") }
end

ruby_block "log into dropbox" do
  not_if { ZZ::Exec.logged_into_dropbox? }
  block { ZZ::Exec.open_dropbox }
end
