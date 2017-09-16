ruby_block "install dropbox" do
  not_if { ZZ::Exec.dropbox_installed? }
  block { ZZ::Exec.install_dropbox }
end

ruby_block "log into dropbox" do
  not_if { ZZ::Exec.logged_into_dropbox? }

  block do
    ZZ::Exec.open_dropbox

    puts "\nWaiting for Dropbox login..."
    sleep 1 until ZZ::Exec.logged_into_dropbox?
  end
end

ruby_block "wait for sync" do
  not_if { ZZ::Exec.dropbox_synced? }

  block do
    puts "\nWaiting for sync..."
    sleep 1 until ZZ::Exec.dropbox_synced?
  end
end
