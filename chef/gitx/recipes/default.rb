ruby_block "install gitx" do
  not_if { ZZ::Exec.cask_installed?("rowanj-gitx") }
  block { ZZ::Exec.install_cask("rowanj-gitx") }
end
