package "awscli"
package "terraform"

ruby_block "install aws-vault" do
  not_if { ZZ::Exec.cask_installed?("aws-vault") }
  block { ZZ::Exec.install_cask("aws-vault") }
end
