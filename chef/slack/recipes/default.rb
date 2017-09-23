ruby_block "install slack" do
  not_if { ZZ::Exec.slack_installed? }
  block { ZZ::Exec.install_slack }
end
