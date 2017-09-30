ruby_block "install slack" do
  not_if { ZZ::Exec.cask_installed?("slack") }
  block { ZZ::Exec.install_cask("slack") }
end
