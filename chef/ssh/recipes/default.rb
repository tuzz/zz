package "openssh"

cookbook_file "use gpg for ssh authentication" do
  source "gpg_agent_config"
  path ZZ::Path.gpg_agent_config
end

ruby_block "lock down ssh to key-based authentication" do
  not_if { ZZ::Exec.sshd_config_written? }
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

cookbook_file "authorized keys" do
  source "public_ssh_key"
  path ZZ::Path.authorized_keys
  mode "644"
end

cookbook_file "ssh config" do
  source "ssh_config"
  path ZZ::Path.ssh_config
  mode "644"
end
