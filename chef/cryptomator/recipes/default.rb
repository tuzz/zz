ruby_block "install cryptomator" do
  not_if { ZZ::Exec.cask_installed?("cryptomator") }
  block { ZZ::Exec.install_cask("cryptomator") }
end

ruby_block "hide cryptomator dock icon" do
  not_if { ZZ::Exec.cryptomator_dock_icon_hidden? }
  block { ZZ::Exec.hide_cryptomator_dock_icon }
end
