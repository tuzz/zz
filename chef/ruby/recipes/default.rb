package "rbenv"

ruby_block "install latest Ruby MRI" do
  not_if { ZZ::Exec.latest_ruby_installed? }
  block { ZZ::Exec.install_latest_ruby }
end

ruby_block "set global Ruby" do
  not_if { ZZ::Exec.global_ruby_set? }
  block { ZZ::Exec.set_global_ruby }
end

file "gem config" do
  path ZZ::Path.gem_config
  content "gem: --no-document"
end
