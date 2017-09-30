ruby_block "install vlc" do
  not_if { ZZ::Exec.cask_installed?("vlc") }
  block { ZZ::Exec.install_cask("vlc") }
end
