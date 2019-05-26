module ZZ
  module Complete
    class << self
      def execute(args)
        list = complete_command(args) || complete_option(args) || complete_option_args(args) || []

        print list.join(" ")
      end

      def name
        "complete"
      end

      def summary
        "autocompletes a zz command"
      end

      def description
        [
          "This command provides autocompletion support for zz. It is called",
          "when you hit tab as you are typing in a command.",
        ].join("\n  ")
      end

      def options
        []
      end

      private

      def complete_command(args)
        commands = filter_commands(args)

        return false if args.size > 2
        return false if exact_command_match?(commands, args)

        commands.map(&:name)
      end

      def complete_option(args)
        command = filter_commands(args).first

        return false unless command
        return false if args.size > 2 && !option_like?(args.last)

        options = filter_options(command, args.last)

        if exact_option_match?(options, args)
          return false if options.first.arity > 0

          options = command.options
        end

        options.map { |o| "--#{o.long}" }
      end

      def complete_option_args(args)
        command = filter_commands(args).first
        return false unless command

        option = find_last_option(command, args)
        return false unless option

        completion_proc = option.complete
        return false unless completion_proc

        args = add_empty_arg_if_ends_in_option(args, option)
        completion_proc[args]
      end

      def filter_commands(args)
        ZZ::COMMANDS.select { |c| c.name.start_with?(args[1] || "") }
      end

      def filter_options(command, arg)
        command.options.select { |o| o.long.start_with?(de_option(arg)) }
      end

      def exact_command_match?(commands, args)
        commands.map(&:name) == [args[1]]
      end

      def exact_option_match?(options, args)
        options.map(&:long) == [de_option(args.last)]
      end

      def find_last_option(command, args)
        args.reverse
          .map { |arg| filter_options(command, arg) }
          .map { |arr| arr.first if arr.size == 1 }
          .compact
          .first
      end

      # This is for convenience so that the completion_procs don't need to
      # check if the last argument was actually the '--foo' option argument.
      def add_empty_arg_if_ends_in_option(args, option)
        de_option(args.last) == option.long ? args + [""] : args
      end

      def de_option(name)
        option_like?(name) ? name.sub(/-+/, "") : ""
      end

      def option_like?(arg)
        arg && arg.start_with?("-")
      end
    end
  end
end
