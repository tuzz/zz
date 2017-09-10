module ZZ
  COMMANDS = [Debug, Provision]

  def self.execute(args)
    command_name = args.shift

    command = COMMANDS.detect do |c|
      c.name == command_name
    end

    if command.nil?
      puts Help.usage(COMMANDS)
      return
    end

    command.execute(args)
  end
end
