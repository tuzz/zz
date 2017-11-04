ruby_block "install drivers for wacom intuous tablet" do
  not_if { ZZ::Exec.cask_installed?("wacom-intuos-tablet") }
  block { ZZ::Exec.install_cask("wacom-intuos-tablet") }
end
