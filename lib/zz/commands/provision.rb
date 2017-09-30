module ZZ
  module Provision
    class << self
      attr_accessor :matches

      def execute(args)
        @matches = Option.matches(options, args)

        if matches[print_option].any?
          print_script
        elsif matches[edit_option].any?
          edit_script
        elsif matches[list_option].any?
          list_scripts
        else
          run_chef
        end
      end

      def name
        "provision"
      end

      def summary
        "sets up a machine for development"
      end

      def description
        [
          "This command is designed to run on a fresh install of macOS.",
          "It configures system preferences and installs a lot of things,",
          "such as programming languages, web browsers, the best text editor",
          "and other development tools."
        ].join("\n  ")
      end

      def options
        [only_option, print_option, edit_option, list_option]
      end

      private

      def print_script
        script = matches[print_option].last.args
        puts File.read(script_path(script))
      end

      def edit_script
        script = matches[edit_option].last.args

        File.read(script_path(script))
        Exec.edit(script_path(script))
      end

      def list_scripts
        Dir["#{Path.chef_cookbooks}/*"]
          .select { |path| File.directory?(path) }.sort
          .each { |dir| puts File.basename(dir) }
      end

      def run_chef
        Exec.install_chef unless Exec.chef_installed?

        Exec.grant_permissions
        Exec.run_chef(run_list)
      ensure
        Exec.revoke_permissions
      end

      def run_list
        match = matches[only_option].last
        match.args.first if match
      end

      def script_path(script)
        File.join(Path.chef_cookbooks, script, "recipes", "default.rb")
      end

      def only_option
        help = "only run these scripts (e.g. homebrew,vim)"
        @only_option ||= Option.new("o", "only", 1, help)
      end

      def list_option
        help = "list available provisioning scripts"
        @list_option ||= Option.new("l", "list", 0, help)
      end

      def print_option
        help = "print this script to stdout"
        @print_option ||= Option.new("p", "print", 1, help)
      end

      def edit_option
        help = "open this script in your editor"
        @edit_option ||= Option.new("e", "edit", 1, help)
      end
    end
  end
end
