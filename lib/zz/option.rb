module ZZ
  class Option
    def self.matches(options, args)
      args = args.dup
      matches = Hash.new { |k, v| k[v] = [] }

      loop do
        m = options.map { |o| o.match(args) }.compact
        return matches if m.empty?
        m.each { |match| matches[match.option] << match }
      end
    end

    attr_accessor :short, :long, :arity, :summary, :complete

    def initialize(short, long, arity, summary, &complete)
      self.short = short
      self.long = long
      self.arity = arity
      self.summary = summary
      self.complete = complete
    end

    def match(args)
      expected = %W(-#{short} --#{short} -#{long} --#{long})
      actual = args.first

      if expected.any? { |e| e == actual }
        args.shift
        match_args = arity.times.map { args.shift }

        Match.new(self, match_args)
      end
    end

    class Match
      attr_accessor :option, :args

      def initialize(option, args)
        self.option = option
        self.args = args
      end
    end
  end
end
