package "gpg2"

ruby_block "import gpg key" do
  not_if { ZZ::Exec.gpg_key_imported? }

  block do
    ZZ::Exec.import_private_gpg_key
    ZZ::Exec.import_public_gpg_key
  end
end

ruby_block "trust gpg key" do
  not_if { ZZ::Exec.gpg_key_trusted? }
  block { ZZ::Exec.trust_gpg_key }
end
