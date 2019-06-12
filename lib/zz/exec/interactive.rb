module ZZ
  module Exec
    class Interactive < Struct.new(:command, :interactions)
      def run
        expected = interactions.delete(:expect)
        actual = interact_with_command

        must_match!(expected, actual)

        actual
      end

      def interact_with_command
        output = []

        PTY.spawn(command) do |stdout, stdin|
          interactions.each do |question, answer|
            stdout.expect(/#{question}/i)
            stdin.puts(answer)
            stdout.gets
          end

          while line = stdout.gets
            output << line.to_s.strip
          end
        end

        output.join("\n")
      end

      def must_match!(expected, actual)
        return if expected.nil?
        return if actual.match(/#{expected}/)

        raise "Expected '#{expected}' but got '#{actual}'"
      end
    end
  end
end
