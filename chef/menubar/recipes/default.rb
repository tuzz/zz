ruby_block "autohide the menu bar" do
  not_if { ZZ::Exec.menubar_autohide? }
  block { ZZ::Exec.autohide_menubar }
end
