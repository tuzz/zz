ruby_block "install transmission" do
  not_if { ZZ::Exec.transmission_installed? }
  block { ZZ::Exec.install_transmission }
end
