ruby_block "install chrome" do
  not_if { ZZ::Exec.cask_installed?("google-chrome") }
  block { ZZ::Exec.install_cask("google-chrome") }
end
