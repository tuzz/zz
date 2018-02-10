remote_file "download mysides cli utility" do
  not_if { ZZ::Exec.mysides_installed? }

  source ZZ::Path.mysides_remote_package
  path   ZZ::Path.mysides_local_package
end

ruby_block "install mysides" do
  not_if { ZZ::Exec.mysides_installed? }
  block { ZZ::Exec.install_mysides }
end

ruby_block "configure sidebar" do
  not_if { ZZ::Exec.sidebar_items.count == 6 }

  block do
    ZZ::Exec.sidebar_items.each do |name|
      ZZ::Exec.remove_sidebar_item(name)
    end

    whoami = ZZ::Exec.whoami

    ZZ::Exec.add_sidebar_item(whoami, "file:///Users/#{whoami}/")
    ZZ::Exec.add_sidebar_item("code", "file:///Users/#{whoami}/code/")
    ZZ::Exec.add_sidebar_item("vault", "file:///Volumes/vault/")
    ZZ::Exec.add_sidebar_item("hdd", "file:///Volumes/hdd/")
    ZZ::Exec.add_sidebar_item("desktop", "file:///Users/#{whoami}/Desktop/")
    ZZ::Exec.add_sidebar_item("downloads", "file:///Users/#{whoami}/Downloads/")
  end
end
