ruby_block "install vagrant" do
  not_if { ZZ::Exec.vagrant_installed? }
  block { ZZ::Exec.install_vagrant }
end
