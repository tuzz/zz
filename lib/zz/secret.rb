module ZZ
  module Secret
    class << self
      def read(*name)
        Exec.capture("gpg --decrypt #{path(*name)} 2> /dev/null").tap do |secret|
          raise SecretNotFoundError, path(*name) if secret.empty?
        end
      end

      def path(*name)
        File.join(Path.secrets, *name) + ".gpg"
      end
    end

    class ::SecretNotFoundError < StandardError; end
  end
end
