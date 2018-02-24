module ZZ
  COMMANDS = [Debug, Provision, Template, Update]

  def self.execute(args)
    command_name = args.shift

    command = COMMANDS.detect do |c|
      c.name.start_with?(command_name || "_")
    end

    if command.nil?
      puts Help.usage(COMMANDS)
      return
    end

    command.execute(args)
  end
end
