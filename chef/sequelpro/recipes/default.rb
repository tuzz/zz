ruby_block "install sequel pro" do
  not_if { ZZ::Exec.sequel_pro_installed? }
  block { ZZ::Exec.install_sequel_pro }
end
