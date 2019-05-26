module ZZ
  module Provision
    class << self
      attr_accessor :matches

      def execute(args)
        @matches = Option.matches(options, args)

        if matches[print_option].any?
          print_recipe
        elsif matches[edit_option].any?
          edit_recipe
        elsif matches[list_option].any?
          list_recipes
        else
          run_chef
        end
      end

      def name
        "provision"
      end

      def summary
        "sets up a machine for development"
      end

      def description
        [
          "This command is designed to run on a fresh install of macOS.",
          "It configures system preferences and installs a lot of things,",
          "such as programming languages, web browsers, the best text editor",
          "and other development tools."
        ].join("\n  ")
      end

      def options
        [only_option, print_option, edit_option, list_option]
      end

      private

      def print_recipe
        recipe = matches[print_option].last.args
        puts File.read(recipe_path(recipe))
      end

      def edit_recipe
        recipe = matches[edit_option].last.args

        File.read(recipe_path(recipe))
        Exec.edit(recipe_path(recipe))
      end

      def list_recipes
        recipes.each { |r| puts r }
      end

      def recipes
        Dir["#{Path.chef_cookbooks}/*"]
          .select { |path| File.directory?(path) }
          .map { |dir| File.basename(dir) }
          .sort
      end

      def run_chef
        Exec.install_chef unless Exec.chef_installed?

        Exec.grant_permissions
        Exec.run_chef(run_list)
      ensure
        Exec.revoke_permissions
      end

      def run_list
        match = matches[only_option].last
        match.args.first if match
      end

      def recipe_path(recipe)
        File.join(Path.chef_cookbooks, recipe, "recipes", "default.rb")
      end

      def only_option
        help = "run a subset of recipes (e.g. homebrew,vim)"

        @only_option ||= Option.new("o", "only", 1, help) do |args|
          auto_complete_recipe_list(args)
        end
      end

      def list_option
        help = "list available recipes"
        @list_option ||= Option.new("l", "list", 0, help)
      end

      def print_option
        help = "print a recipe to stdout"

        @print_option ||= Option.new("p", "print", 1, help) do |args|
          auto_complete_single_recipe(args)
        end
      end

      def edit_option
        help = "open a recipe in your editor"

        @edit_option ||= Option.new("e", "edit", 1, help) do |args|
          auto_complete_single_recipe(args)
        end
      end

      def auto_complete_single_recipe(args)
        list = recipes.select { |t| t.start_with?(args.last.downcase) }
        list == [args.last] ? [] : list
      end

      def auto_complete_recipe_list(args)
        *head, prefix = args.last.downcase.split(",")
        list = recipes.select { |r| r.start_with?(prefix || "") }

        return recipes if list == [prefix]

        list.map { |l| (head + [l]).join(",") }
      end
    end
  end
end
