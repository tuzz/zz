ruby_block "install android studio" do
  not_if { ZZ::Exec.cask_installed?("android-studio") }
  block { ZZ::Exec.install_cask("android-studio") }
end

# TODO: set up a virtual device, e.g. Google Pixel
