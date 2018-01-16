package "ffmpeg" do
  options "--with-fdk-aac --with-x265"
end

cookbook_file "transcode" do
  path ZZ::Path.transcode
  mode "755"
end
