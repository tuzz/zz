package "git"

cookbook_file "set the global config file" do
  source "git_config"
  path ZZ::Path.git_config
end

cookbook_file "set the global ignore file" do
  source "git_ignore"
  path ZZ::Path.git_ignore
end

cookbook_file "make a function that returns the git branch" do
  source "git_branch"
  path ZZ::Path.git_branch
  mode "755"
end
