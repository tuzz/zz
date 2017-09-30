ruby_block "install vlc" do
  not_if { ZZ::Exec.vlc_installed? }
  block { ZZ::Exec.install_vlc }
end
