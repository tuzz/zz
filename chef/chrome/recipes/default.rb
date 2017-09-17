ruby_block "install dropbox" do
  not_if { ZZ::Exec.chrome_installed? }
  block { ZZ::Exec.install_chrome }
end
