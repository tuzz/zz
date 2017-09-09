module ZZ
  module Exec
    def self.execute(command)
      system(command)
    end

    def self.capture(command)
      `#{command}`
    end
  end
end
