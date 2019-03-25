postgres = "postgresql@9.5"

package postgres

ruby_block "start postgres" do
  not_if { ZZ::Exec.service_started?(postgres) }
  block { ZZ::Exec.start_service(postgres) }
end
