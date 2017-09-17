package "nodenv"

ruby_block "install latest node" do
  not_if { ZZ::Exec.latest_node_installed? }
  block { ZZ::Exec.install_latest_node }
end

ruby_block "set global node" do
  not_if { ZZ::Exec.global_node_set? }
  block { ZZ::Exec.set_global_node }
end
