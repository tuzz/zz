module ZZ
  module Complete
    class << self
      def execute(args)
        puts "hello world"
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
    end
  end
end
