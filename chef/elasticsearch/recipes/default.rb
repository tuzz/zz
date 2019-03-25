ruby_block "install java 8" do
  not_if { ZZ::Exec.cask_installed?("java8") }
  block { ZZ::Exec.install_cask("java8") }
end

package "elasticsearch@6.6"

ruby_block "start elasticsearch" do
  not_if { ZZ::Exec.service_started?("elasticsearch") }
  block { ZZ::Exec.start_service("elasticsearch") }
end
