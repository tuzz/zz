ruby_block "install trailer" do
  not_if { ZZ::Exec.cask_installed?("trailer") }
  block { ZZ::Exec.install_cask("trailer") }
end
