module ZZ
  module Pref
    class << self
      def read(domain, key)
        value = Exec.capture("defaults read #{domain} #{key} 2>&1").strip
        value.match(/does not exist/) ? nil : value
      end

      def write(domain, key, type, value)
        Exec.execute("defaults write #{domain} #{key} -#{type} '#{value}'")
      end

      def iterm_config_enabled
        bool(Pref.read(iterm_domain, "LoadPrefsFromCustomFolder"))
      end

      def iterm_config_enabled=(value)
        Pref.write(iterm_domain, "LoadPrefsFromCustomFolder", "bool", value)
      end

      def iterm_config_directory
        Pref.read(iterm_domain, "PrefsCustomFolder")
      end

      def iterm_config_directory=(value)
        Pref.write(iterm_domain, "PrefsCustomFolder", "string", value)
      end

      private

      def iterm_domain
        "com.googlecode.iterm2"
      end

      def bool(value)
        { "0" => false, "1" => true }.fetch(value, nil)
      end
    end
  end
end
