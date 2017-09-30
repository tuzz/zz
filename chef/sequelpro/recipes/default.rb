ruby_block "install sequel pro" do
  not_if { ZZ::Exec.cask_installed?("sequel-pro") }
  block { ZZ::Exec.install_cask("sequel-pro") }
end
