ruby_block "install grand perspective" do
  not_if { ZZ::Exec.grand_perspective_installed? }
  block { ZZ::Exec.install_grand_perspective }
end
