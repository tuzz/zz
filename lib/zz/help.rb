module ZZ
  module Help
    class << self
      def usage(commands)
        io = StringIO.new

        print_summary(io, commands)
        print_detailed(io, commands)

        io.string
      end

      def print_summary(io, commands)
        io.puts "The tuzz automation tool"
        io.puts
        io.puts "For automating all aspects of the 'tuzz' life experience."
        io.puts
        io.puts "Running this tool as a 'non-tuzz' life form could have"
        io.puts "disastrous effects, including, but not limited to, an"
        io.puts "obsession to discover pangrams and a tendency to build"
        io.puts "narcissistic self-referential tools. You have been warned."
        io.puts
        io.puts "Usage: zz <command> [options]"
        io.puts
        io.puts "Commands:"

        commands.each do |command|
          io.puts "  #{command.name}: #{command.summary}"
        end

        io.puts
      end

      def print_detailed(io, commands)
        commands.each do |command|
          io.puts "#{command.name}:"
          io.puts "  #{command.description}"
          io.puts

          command.options.each do |option|
            io.puts "  -#{option.short}, --#{option.long}, #{option.summary}"
          end

          io.puts
        end
      end
    end
  end
end
