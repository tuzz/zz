cookbook_file "user profile" do
  source "user_profile"
  path ZZ::Path.user_profile
end

file "silence last login" do
  content ""
  path ZZ::Path.hushlogin
end
