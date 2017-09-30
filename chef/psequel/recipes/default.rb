ruby_block "install psequel" do
  not_if { ZZ::Exec.cask_installed?("psequel") }
  block { ZZ::Exec.install_cask("psequel") }
end
