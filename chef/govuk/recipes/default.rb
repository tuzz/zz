package "openconnect"

directory "code" do
  path ZZ::Path.code
end

git "clone govuk-puppet" do
  action :checkout
  repository "https://github.com/alphagov/govuk-puppet"
  destination ZZ::Path.govuk_puppet
end

ruby_block "provision dev vm" do
  not_if { ZZ::Exec.dev_vm_provisioned? }
  block { ZZ::Exec.provision_dev_vm }
end

ruby_block "install vagrant-dns plugin" do
  not_if { ZZ::Exec.vagrant_dns_installed? }
  block { ZZ::Exec.install_vagrant_dns }
end

ruby_block "register dns resolver" do
  not_if { ZZ::Exec.dns_resolver_registered? }
  block { ZZ::Exec.register_dns_resolver }
end

ruby_block "write ssh config" do
  not_if { ZZ::Exec.ssh_config_exists? }
  block { ZZ::Exec.write_ssh_config }
end
