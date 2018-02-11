module ZZ
  module Template
    class << self
      NAME_REGEX = /^[a-z][^\s]*$/i

      attr_accessor :proj_name, :proj_type, :copyright

      def execute(args)
        self.proj_type = fetch_type
        self.proj_name = fetch_name
        self.copyright = fetch_copyright

        copy_template

        recursively_replace("name", proj_name)
        recursively_replace("copyright", copyright)

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
        []
      end

      private

      def fetch_type
        print "Which type? (#{types.join("/")}): "
        type = $stdin.gets.strip

        return type if types.include?(type)
        raise ArgumentError, "Unknown template type '#{type}'"
      end

      def fetch_name
        print "Project name: "
        name = $stdin.gets.strip

        return name if name.match(NAME_REGEX)
        raise ArgumentError, "Invalid project name '#{name}'"
      end

      # TODO: make this configurable
      def fetch_copyright
        "#{Time.new.year} Chris Patuzzo <chris@patuzzo.co.uk>"
      end

      def copy_template
        source = "#{ZZ::Path.templates}/#{proj_type}"

        if File.exist?(directory)
          raise ArgumentError, "Something already exists by that name."
        end

        FileUtils.cp_r(source, directory)
      end

      def recursively_replace(key, value)
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

      def camel_case(string)
        string.split("_").collect(&:capitalize).join
      end
    end
  end
end
