cookbook_file "install scan script" do
  source "scan"
  path ZZ::Path.scan
  mode "755"
end
