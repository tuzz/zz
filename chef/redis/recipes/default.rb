package "redis"

ruby_block "start redis" do
  not_if { ZZ::Exec.service_started?("redis") }
  block { ZZ::Exec.start_service("redis") }
end
