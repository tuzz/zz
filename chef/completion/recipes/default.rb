cookbook_file "autocompletion for zz" do
  source "zz_completion"
  path ZZ::Path.zz_completion
end
