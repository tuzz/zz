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

ruby_block "start minidlna" do
  not_if { ZZ::Exec.service_started?("minidlna") }
  only_if { File.directory?(ZZ::Path.minidlna_media) }

  block { ZZ::Exec.start_service("minidlna") }
end
