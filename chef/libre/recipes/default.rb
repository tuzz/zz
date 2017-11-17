ruby_block "install libre office" do
  not_if { ZZ::Exec.cask_installed?("libreoffice") }
  block { ZZ::Exec.install_cask("libreoffice") }
end
