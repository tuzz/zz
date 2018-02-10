module ZZ
  module Pref
    class << self
      def read(domain, key)
        value = Exec.capture("defaults read '#{domain}' #{key} 2>&1").strip
        value.match(/does not exist/) ? nil : value
      end

      def write(domain, key, type, value = nil)
        value = " '#{value}'" if value
        Exec.execute("defaults write '#{domain}' #{key} -#{type}#{value}")
      end

      def import(domain, path)
        Exec.execute("defaults import #{domain} #{path}")
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

      def menubar_autohide
        bool(Pref.read(global_domain, "_HIHideMenuBar"))
      end

      def menubar_autohide=(value)
        Pref.write(global_domain, "_HIHideMenuBar", "int", value)
      end

      def dock_apps
        Pref.read(dock_domain, "persistent-apps").gsub(/\s/, "")
      end

      def dock_apps=(value)
        raise NotImplementedError unless value == "()"
        Pref.write(dock_domain, "persistent-apps", "array")
      end

      def dock_others
        Pref.read(dock_domain, "persistent-others").gsub(/\s/, "")
      end

      def dock_others=(value)
        raise NotImplementedError unless value == "()"
        Pref.write(dock_domain, "persistent-others", "array")
      end

      def dock_size
        int(Pref.read(dock_domain, "tilesize"))
      end

      def dock_size=(value)
        Pref.write(dock_domain, "tilesize", "int", value)
      end

      def dock_orientation
        Pref.read(dock_domain, "orientation")
      end

      def dock_orientation=(value)
        Pref.write(dock_domain, "orientation", "string", value)
      end

      def dock_autohide
        bool(Pref.read(dock_domain, "autohide"))
      end

      def dock_autohide=(value)
        Pref.write(dock_domain, "autohide", "bool", value)
      end

      def screenflow_helper_audio
        domain = screenflow_helper_domain
        Pref.read(domain, "captureComputerAudioEnabled")
      end

      def screenflow_helper_audio=(value)
        domain = screenflow_helper_domain
        Pref.write(domain, "captureComputerAudioEnabled", "int", value)
      end

      def import_screenflow_config(path)
        Pref.import(screenflow_domain, path)
      end

      private

      def global_domain
        "Apple Global Domain"
      end

      def iterm_domain
        "com.googlecode.iterm2"
      end

      def dock_domain
        "com.apple.dock"
      end

      def screenflow_domain
        "net.telestream.screenflow7"
      end

      def screenflow_helper_domain
        "WSG985FR47.net.telestream.screenflowhelper"
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
