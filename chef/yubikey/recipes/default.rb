# For general device setup, e.g. setting static passwords:
ruby_block "install yubikey personalisation tool" do
  not_if { ZZ::Exec.cask_installed?("yubico-yubikey-personalization-gui") }
  block { ZZ::Exec.install_cask("yubico-yubikey-personalization-gui") }
end

# For creating mfa credentials, e.g. aws web console:
ruby_block "install yubico authenticator" do
  not_if { ZZ::Exec.cask_installed?("yubico-authenticator") }
  block { ZZ::Exec.install_cask("yubico-authenticator") }
end

# For CLI usage, e.g. retrieving mfa codes:
package "ykman"
