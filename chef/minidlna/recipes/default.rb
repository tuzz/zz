package "minidlna"

directory "create minidlna directory" do
  path ZZ::Path.minidlna_directory
  mode "700"
  recursive true
end

cookbook_file "minidlna config" do
  source "minidlna_config"
  path ZZ::Path.minidlna_config
end

cookbook_file "reindex command" do
  source "reindex"
  path ZZ::Path.minidlna_reindex
  mode "755"
end

ruby_block "start minidlna" do
  not_if { ZZ::Exec.service_started?("minidlna") }
  only_if { File.directory?(ZZ::Path.minidlna_media) }

  block { ZZ::Exec.start_service("minidlna") }
end
