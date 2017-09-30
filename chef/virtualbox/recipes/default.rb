ruby_block "install virtualbox" do
  not_if { ZZ::Exec.virtualbox_installed? }
  block { ZZ::Exec.install_virtualbox }
end
