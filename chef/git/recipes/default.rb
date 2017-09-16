package "git"

cookbook_file "git config" do
  source "git_config"
  path ZZ::Path.git_config
end

cookbook_file "git ignore" do
  source "git_ignore"
  path ZZ::Path.git_ignore
end

ruby_block "intialize git repo" do
  not_if { ZZ::Exec.git_repo_initialized? }
  block { ZZ::Exec.initialize_git_repo }
end
