ruby_block "install grand perspective" do
  not_if { ZZ::Exec.cask_installed?("grandperspective") }
  block { ZZ::Exec.install_cask("grandperspective") }
end
