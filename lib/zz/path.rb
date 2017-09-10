module ZZ
  module Path
    class << self
      def to(path)
        File.expand_path("../../#{path}", __dir__)
      end

      def root
        to(nil)
      end

      def tmp
       to("tmp")
      end

      def chef_cookbooks
        to("chef")
      end

      def chef_run_list
        to("chef/node.json")
      end

      def chef_cache
        tmp
      end

      def chef_config
        to("chef/config.rb")
      end
    end
  end
end
