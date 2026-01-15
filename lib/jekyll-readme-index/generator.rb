# frozen_string_literal: true

module JekyllReadmeIndex
  class Generator < Jekyll::Generator
    INDEX_REGEX = %r!$|index\.(html?|xhtml|xml)$!i.freeze
    GITHUB_DIR = "/.github"
    DOCS_DIR = "/docs"
    SPECIAL_DIRS = [GITHUB_DIR, DOCS_DIR].freeze
    GITHUB_README_PATTERN = %r!^/\.github/readme!i.freeze
    DOCS_README_PATTERN = %r!^/docs/readme!i.freeze
    ROOT_README_PATTERN = %r!^/readme!i.freeze

    attr_accessor :site

    safe true
    priority :low

    CONFIG_KEY = "readme_index"
    ENABLED_KEY = "enabled"
    CLEANUP_KEY = "remove_originals"
    FRONTMATTER_KEY = "with_frontmatter"
    PATTERN_KEY = "readme_pattern"

    def initialize(site)
      @site = site
    end

    def generate(site)
      @site = site
      return if disabled?

      readmes.each do |readme|
        next unless should_be_index?(readme)

        site.pages << readme.to_page
        site.static_files.delete(readme) if cleanup?
      end

      if with_frontmatter?
        readmes_with_frontmatter.each do |readme|
          next unless should_be_index?(readme)

          readme.update_permalink
        end
      end
    end

    private

    # Returns an array of all READMEs as StaticFiles
    def readmes
      candidates = site.static_files.select { |file| file.relative_path =~ readme_regex }
      prioritize_readmes(candidates)
    end

    def readmes_with_frontmatter
      candidates = site.pages.select { |file| ("/" + file.path) =~ readme_regex }
      prioritize_readmes(candidates)
    end

    # Prioritize READMEs according to GitHub's order: .github > root > docs
    # For each target directory, keep only the highest priority README
    # rubocop:disable Metrics/PerceivedComplexity
    def prioritize_readmes(candidates)
      grouped = candidates.group_by do |file|
        # Get the directory that would become the index
        # READMEs in .github and docs should serve as index for parent directory
        # Note: file_path returns Jekyll-normalized paths without query strings
        dir = File.dirname(file_path(file))

        # If the README is in .github or docs subdirectory at root,
        # it should be the index for root
        if SPECIAL_DIRS.include?(dir)
          "/"
        else
          dir
        end
      end

      grouped.flat_map do |_dir, files|
        # Sort by priority: .github first, then root, then docs, then others
        files.min_by do |file|
          path = file.respond_to?(:relative_path) ? file.relative_path : "/" + file.path
          case path
          when GITHUB_README_PATTERN then 0
          when ROOT_README_PATTERN then 1
          when DOCS_README_PATTERN then 2
          else 3
          end
        end
      end.compact
    end
    # rubocop:enable Metrics/PerceivedComplexity

    # Should the given readme be the containing directory's index?
    def should_be_index?(readme)
      return false unless readme

      !dir_has_index? File.dirname(readme.url)
    end

    # Does the given directory have an index?
    #
    # relative_path - the directory path relative to the site root
    def dir_has_index?(relative_path)
      relative_path << "/" unless relative_path.end_with? "/"
      regex = %r!^#{Regexp.escape(relative_path)}#{INDEX_REGEX}!i
      (site.pages + site.static_files).any? { |file| file.url =~ regex }
    end

    # Regexp to match a file path against to detect if the given file is a README
    def readme_regex
      # Allow custom pattern override via configuration
      @readme_regex ||= if (custom_pattern = option(PATTERN_KEY))
                          Regexp.new(custom_pattern, Regexp::IGNORECASE)
                        else
                          # Match README in any directory, including .github, docs subdirectories
                          # The pattern ensures .github and docs are only matched at path boundaries
                          extensions = Regexp.union(markdown_converter.extname_list)
                          %r!/(?:\.github/|docs/)?readme(#{extensions})$!i
                        end
    end

    def markdown_converter
      @markdown_converter ||= site.find_converter_instance(Jekyll::Converters::Markdown)
    end

    def option(key)
      site.config[CONFIG_KEY] && site.config[CONFIG_KEY][key]
    end

    def disabled?
      option(ENABLED_KEY) == false
    end

    def cleanup?
      option(CLEANUP_KEY) == true
    end

    def with_frontmatter?
      option(FRONTMATTER_KEY) == true
    end

    # Helper method to get the file path (URL or path) for a file object
    def file_path(file)
      file.respond_to?(:url) ? file.url : "/" + file.path
    end
  end
end
