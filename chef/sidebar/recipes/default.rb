remote_file "download mysides cli utility" do
  not_if { ZZ::Exec.mysides_installed? }

  source ZZ::Path.mysides_remote_package
  path   ZZ::Path.mysides_local_package
end

ruby_block "install mysides" do
  not_if { ZZ::Exec.mysides_installed? }
  block { ZZ::Exec.install_mysides }
end

directory "code" do
  path ZZ::Path.code
end

ruby_block "configure sidebar" do
  not_if { ZZ::Exec.sidebar_items.count == 8 }

  block do
    whoami = ZZ::Exec.whoami

    desired_items = {
      whoami => "file:///Users/#{whoami}/",
      "code" => "file:///Users/#{whoami}/code/",
      "vault" => "file:///Volumes/vault/",
      "hdd" => "file:///Volumes/hdd/",
      "applications" => "file:///Applications/",
      "dropbox" => "file:///Users/#{whoami}/Dropbox/",
      "desktop" => "file:///Users/#{whoami}/Desktop/",
      "downloads" => "file:///Users/#{whoami}/Downloads/",
    }

    desired_items.keys.each do |name|
      ZZ::Exec.remove_sidebar_item(name)
    end

    ZZ::Exec.sidebar_items.each do |name|
      ZZ::Exec.remove_sidebar_item(name)
    end

    desired_items.each do |name, path|
      ZZ::Exec.add_sidebar_item(name, path)
    end
  end
end
