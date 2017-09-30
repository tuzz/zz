ruby_block "empty the dock" do
  not_if { ZZ::Exec.empty_dock? }
  block { ZZ::Exec.empty_dock! }

  notifies :run, "ruby_block[restart dock]", :delayed
end

ruby_block "set smallest dock" do
  not_if { ZZ::Exec.smallest_dock? }
  block { ZZ::Exec.set_smallest_dock }

  notifies :run, "ruby_block[restart dock]", :delayed
end

ruby_block "move dock to the right of the screen" do
  not_if { ZZ::Exec.dock_right_of_screen? }
  block { ZZ::Exec.move_dock_right_of_screen }

  notifies :run, "ruby_block[restart dock]", :delayed
end

ruby_block "autohide the dock" do
  not_if { ZZ::Exec.dock_autohide? }
  block { ZZ::Exec.autohide_dock }

  notifies :run, "ruby_block[restart dock]", :delayed
end

ruby_block "restart dock" do
  block { ZZ::Exec.restart_dock }
  action :nothing
end
