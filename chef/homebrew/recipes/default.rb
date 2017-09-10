remote_file "download homebrew installer" do
  not_if { ZZ::Exec.homebrew_installed? }

  source ZZ::Path.homebrew_remote_installer
  path   ZZ::Path.homebrew_local_installer

  mode "500"
end

bash "install homebrew" do
  not_if { ZZ::Exec.homebrew_installed? }

  code ZZ::Path.homebrew_local_installer
end
