ruby_block "intialize git repo for zz" do
  not_if { ZZ::Exec.zz_repo_initialized? }

  block do
    ZZ::Exec.zz_git_init
    ZZ::Exec.zz_git_remote_add
    ZZ::Exec.gpg_reset
    ZZ::Exec.zz_git_fetch
    ZZ::Exec.zz_git_reset
  end
end

cookbook_file "autocompletion for zz" do
  source "zz_completion"
  path ZZ::Path.zz_completion
end
