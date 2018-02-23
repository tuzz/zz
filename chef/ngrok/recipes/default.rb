ruby_block "install ngrok" do
  not_if { ZZ::Exec.cask_installed?("ngrok") }
  block { ZZ::Exec.install_cask("ngrok") }
end
