ruby_block "install screenflow" do
  not_if { ZZ::Exec.cask_installed?("screenflow") }
  block { ZZ::Exec.install_cask("screenflow") }
end

ruby_block "configure screenflow" do
  not_if { ZZ::Exec.screenflow_configured? }
  block { ZZ::Exec.configure_screenflow }
end
