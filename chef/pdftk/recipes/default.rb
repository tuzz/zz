remote_file "download pdftk installer" do
  not_if { ZZ::Exec.pdftk_installed? }

  source ZZ::Path.pdftk_remote_package
  path   ZZ::Path.pdftk_local_package

  mode "500"
end

ruby_block "install pdftk" do
  not_if { ZZ::Exec.pdftk_installed? }
  block { ZZ::Exec.install_pdftk }
end
