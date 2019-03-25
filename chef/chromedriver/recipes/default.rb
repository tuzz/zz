ruby_block "install chromedriver" do
  not_if { ZZ::Exec.cask_installed?("chromedriver") }
  block { ZZ::Exec.install_cask("chromedriver") }
end
