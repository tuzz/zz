ruby_block "patch ffmpeg recipe" do
  not_if { ZZ::Exec.ffmpeg_patched? }
  block { ZZ::Exec.patch_ffmpeg }
end

package "fdk-aac"

package "ffmpeg" do
  options "--HEAD"
end

cookbook_file "transcode" do
  path ZZ::Path.transcode
  mode "755"
end
