module ZZ
  module Pref
    class << self
      def read(domain, key)
        value = Exec.capture("defaults read '#{domain}' #{key} 2>&1").strip
        value.match(/does not exist/) ? nil : value
      end

      def write(domain, key, type, value)
        Exec.execute("defaults write '#{domain}' #{key} -#{type} '#{value}'")
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

      def key_repeat
        int(Pref.read(global_domain, "KeyRepeat"))
      end

      def key_repeat=(value)
        Pref.write(global_domain, "KeyRepeat", "int", value)
      end

      def key_delay
        int(Pref.read(global_domain, "InitialKeyRepeat"))
      end

      def key_delay=(value)
        Pref.write(global_domain, "InitialKeyRepeat", "int", value)
      end

      private

      def global_domain
        "Apple Global Domain"
      end

      def iterm_domain
        "com.googlecode.iterm2"
      end

      def bool(value)
        { "0" => false, "1" => true }.fetch(value, nil)
      end

      def int(value)
        Integer(value) rescue nil
      end
    end
  end
end
