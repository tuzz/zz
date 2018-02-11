module ZZ
  module Update
    class << self
      def execute(args)
        return if Exec.zz_git_pull

        puts "There are unstaged changes:"
        Exec.zz_git_status
        print "\nDo you want to reset them? (y/N): "

        prompt = gets
        if prompt.strip.downcase == "y"
          Exec.zz_git_checkout
          Exec.zz_git_reset
          Exec.zz_git_pull
        else
          puts "Exiting."
        end
      end

      def name
        "update"
      end

      def summary
        "pulls changes to zz from github"
      end

      def description
        [
          "This command pulls the latest changes to this tool from github. If",
          "there are unstaged changes, zz will prompt the user as to whether",
          "they want to reset their changes.",
        ].join("\n  ")
      end

      def options
        []
      end
    end
  end
end
