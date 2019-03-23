package "nodenv"

ruby_block "install latest node" do
  not_if { ZZ::Exec.latest_node_installed? }
  block { ZZ::Exec.install_latest_node }
end

ruby_block "set global node" do
  not_if { ZZ::Exec.global_node_set? }
  block { ZZ::Exec.set_global_node }
end

ruby_block "install yarn" do
  not_if { ZZ::Exec.yarn_installed? }
  block { ZZ::Exec.install_yarn }

  notifies :run, "ruby_block[rehash nodenv]", :immediately
end

ruby_block "rehash nodenv" do
  block { ZZ::Exec.rehash_nodenv }
  action :nothing
end
