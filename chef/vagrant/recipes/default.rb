ruby_block "install vagrant" do
  not_if { ZZ::Exec.cask_installed?("vagrant") }
  block { ZZ::Exec.install_cask("vagrant") }
end
