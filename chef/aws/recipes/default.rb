package "awscli"
package "terraform"
package "terraform_landscape"

ruby_block "install aws-vault" do
  not_if { ZZ::Exec.cask_installed?("aws-vault") }
  block { ZZ::Exec.install_cask("aws-vault") }
end

ruby_block "add vault for personal access keys" do
  not_if { ZZ::Exec.aws_vault_added?("personal") }
  block { ZZ::Exec.add_aws_vault("personal") }
end
