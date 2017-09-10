module ZZ
  module Debug
    class << self
      def execute(args)
        run_pry
      rescue LoadError
        run_irb
      end

      def run_pry
        require "pry"
        ZZ.pry
      end

      def run_irb
        require "irb"
        IRB.start
      end

      def name
        "debug"
      end

      def summary
        "runs an introspective debugger for zz"
      end

      def description
        [
          "This command starts a pry session in the context of the tuzz",
          "automation tool and falls back to irb if pry is unavailable. It is",
          "useful for debugging problems with the tool and for calling library",
          "code in ways that weren't anticipated... or were they?",
        ].join("\n  ")
      end

      def options
        []
      end
    end
  end
end
