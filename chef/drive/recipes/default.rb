ruby_block "install google drive file stream" do
  not_if { ZZ::Exec.cask_installed?("google-drive-file-stream") }
  block { ZZ::Exec.install_cask("google-drive-file-stream") }
end
