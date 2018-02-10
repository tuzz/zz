package "openconnect"

cookbook_file "make a function that connects to the gds vpn" do
  source "vpn"
  path ZZ::Path.vpn
  mode "755"
end
