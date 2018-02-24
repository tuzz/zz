ruby_block "install typora" do
  not_if { ZZ::Exec.cask_installed?("typora") }
  block { ZZ::Exec.install_cask("typora") }
end

cookbook_file "edit" do
  path ZZ::Path.edit
  mode "755"
end
