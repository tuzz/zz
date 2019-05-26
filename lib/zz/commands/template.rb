module ZZ
  module Template
    class << self
      NAME_REGEX = /^[a-z][^\s]*$/i

      attr_accessor :matches, :proj_name, :proj_type, :copyright

      def execute(args)
        self.matches = Option.matches(options, args)

        if matches[list_option].any?
          print_list
          return
        end

        self.proj_type = fetch_type
        self.proj_name = fetch_name
        self.copyright = fetch_copyright

        copy_template
        recursively_replace("name", proj_name)
        recursively_replace("copyright", copyright)
        recursively_replace("year", Time.new.year)
        recursively_rename
        setup_template
      end

      def name
        "template"
      end

      def summary
        "creates a project template"
      end

      def description
        [
          "This command speeds up the process of starting a project by",
          "generating a template in the target language and running a setup",
          "script. Templates can be customised through user prompts.",
        ].join("\n  ")
      end

      def options
        [type_option, name_option, copyright_option, list_option]
      end

      private

      def fetch_type
        type = option_value(type_option)

        unless type
          print "Which type? (#{types.join("/")}): "
          type = $stdin.gets.strip
        end

        return type if types.include?(type)
        raise ArgumentError, "Unknown template type '#{type}'"
      end

      def fetch_name
        name = option_value(name_option)

        unless name
          print "Project name: "
          name = $stdin.gets.strip
        end

        return name if name.match(NAME_REGEX)
        raise ArgumentError, "Invalid project name '#{name}'"
      end

      def fetch_copyright
        copyright = option_value(copyright_option)
        copyright || "Chris Patuzzo <chris@patuzzo.co.uk>"
      end

      def copy_template
        source = "#{ZZ::Path.templates}/#{proj_type}"

        if File.exist?(directory)
          raise ArgumentError, "Something already exists by that name."
        end

        FileUtils.cp_r(source, directory)
      end

      def recursively_replace(key, value)
        value = value.to_s

        project_paths.each do |path|
          next if File.directory?(path)
          content = File.read(path)

          k, v = key, value
          content.gsub!("{#{k}}", v)

          k, v = camel_case(key), camel_case(value)
          content.gsub!("{#{k}}", v)

          File.open(path, "w") { |f| f.write(content) }
        end
      end

      def recursively_rename
        loop do
          from = project_paths
            .sort_by(&:length)
            .detect { |p| p.include?("{name}") }

          break unless from
          to = from.gsub("{name}", proj_name)

          FileUtils.mv(from, to)
        end
      end

      def setup_template
        ZZ::Exec.setup_template(directory)
      end

      def directory
        "#{Dir.pwd}/#{proj_name}"
      end

      def project_paths
        Dir.glob("#{directory}/**/*")
      end

      def types
        listing = Dir.glob("#{ZZ::Path.templates}/*")
        listing.map { |p| File.basename(p) }
      end

      def print_list
        puts "Available template types: #{types.join(", ")}"
      end

      def camel_case(string)
        string.split("_").collect(&:capitalize).join
      end

      def type_option
        help = "sets the type of template (e.g. ruby)"

        @type_option ||= Option.new("t", "type", 1, help) do |args|
          types.select { |t| t.start_with?(args.last) }
        end
      end

      def name_option
        help = "sets the name of the project (snake_case)"
        @name_option ||= Option.new("n", "name", 1, help)
      end

      def copyright_option
        help = "sets the copyright owner for the license"
        @copyright_option ||= Option.new("c", "copyright", 1, help)
      end

      def list_option
        help = "lists available template types"
        @list_option ||= Option.new("l", "list", 0, help)
      end

      def option_value(option)
        match = matches[option].last
        match.args.first if match
      end
    end
  end
end
