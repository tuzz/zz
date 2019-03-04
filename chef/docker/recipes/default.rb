ruby_block "install docker" do
  not_if { ZZ::Exec.cask_installed?("docker") }
  block { ZZ::Exec.install_cask("docker") }
end

package "install docker cli" do
  package_name "docker"
end
