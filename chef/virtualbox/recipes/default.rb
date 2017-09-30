ruby_block "install virtualbox" do
  not_if { ZZ::Exec.cask_installed?("virtualbox") }
  block { ZZ::Exec.install_cask("virtualbox") }
end
