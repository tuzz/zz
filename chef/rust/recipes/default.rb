package "rustup-init"
package "sccache"

ruby_block "rustup" do
  not_if { ZZ::Exec.cargo_configured? }
  block { ZZ::Exec.rustup_nightly }
end

ruby_block "target wasm" do
  not_if { ZZ::Exec.wasm_target? }
  block { ZZ::Exec.target_wasm }
end

ruby_block "install wasm-pack" do
  not_if { ZZ::Exec.wasm_pack_installed? }
  block { ZZ::Exec.install_wasm_pack }
end

ruby_block "install clippy" do
  not_if { ZZ::Exec.clippy_installed? }
  block { ZZ::Exec.install_clippy }
end

ruby_block "install cargo-watch" do
  not_if { ZZ::Exec.cargo_watch_installed? }
  block { ZZ::Exec.install_cargo_watch }
end

ruby_block "install renamer" do
  not_if { ZZ::Exec.renamer_installed? }
  block { ZZ::Exec.install_renamer }
end
