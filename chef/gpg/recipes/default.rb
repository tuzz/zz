package "gpg2"

directory "create gpg directory" do
  path ZZ::Path.gpg_directory
  mode "700"
end

cookbook_file "gpg config" do
  source "gpg_config"
  path ZZ::Path.gpg_config
end

ruby_block "import gpg key" do
  not_if { ZZ::Exec.public_gpg_key_imported? }
  block { ZZ::Exec.import_public_gpg_key }
end

ruby_block "trust gpg key" do
  not_if { ZZ::Exec.gpg_key_trusted? }
  block { ZZ::Exec.trust_gpg_key }
end
