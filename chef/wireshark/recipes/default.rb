ruby_block "install wireshark" do
  not_if { ZZ::Exec.cask_installed?("wireshark") }
  block { ZZ::Exec.install_cask("wireshark") }
end
