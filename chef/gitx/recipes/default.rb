ruby_block "install gitx" do
  not_if { ZZ::Exec.gitx_installed? }
  block { ZZ::Exec.install_gitx }
end
