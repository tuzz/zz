ruby_block "install transmission" do
  not_if { ZZ::Exec.cask_installed?("transmission") }
  block { ZZ::Exec.install_cask("transmission") }
end
