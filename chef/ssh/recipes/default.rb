ruby_block "lock down ssh to key-based authentication" do
  block { ZZ::Exec.write_sshd_config }
  notifies :run, "ruby_block[restart sshd]", :immediately
end

ruby_block "restart sshd" do
  block { ZZ::Exec.restart_sshd }
  action :nothing
end

directory "create ssh directory" do
  path ZZ::Path.ssh_directory
  mode "700"
end

remote_file "private ssh key" do
  source "file://#{ZZ::Path.ssh_backup}"
  path ZZ::Path.private_ssh_key
  mode "600"
end

cookbook_file "public ssh key" do
  source "public_ssh_key"
  path ZZ::Path.public_ssh_key
  mode "644"
end

cookbook_file "authorized keys" do
  source "public_ssh_key"
  path ZZ::Path.authorized_keys
  mode "644"
end
