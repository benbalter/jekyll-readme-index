# frozen_string_literal: true

require "set"

module JekyllReadmeIndex
  class Generator < Jekyll::Generator
    # Captures the directory a URL is the index of, e.g. "/a/" for "/a/" or "/a/index.html"
    INDEX_URL_REGEX = %r!\A(.*/)(?:index\.(?:html?|xhtml|xml))?\z!i.freeze
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
    APPEND_HTML_KEY = "append_html"

    def initialize(site)
      @site = site
    end

    def generate(site)
      @site = site
      @index_dirs = nil
      return if disabled?

      readmes.each do |readme|
        next unless should_be_index?(readme)

        page = to_page(readme)
        site.pages << page
        add_index_dir(page.url)
        site.static_files.delete(readme) if cleanup?
      end

      if with_frontmatter?
        readmes_with_frontmatter.each do |readme|
          next unless should_be_index?(readme)

          add_index_dir(update_permalink(readme))
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
          case readme_path(file)
          when GITHUB_README_PATTERN then 0
          when ROOT_README_PATTERN then 1
          when DOCS_README_PATTERN then 2
          else 3
          end
        end
      end.compact
    end

    # Convert a README StaticFile to a Page that serves as its directory's index
    def to_page(static_file)
      # StaticFile doesn't expose its base, dir, or name (the last only since
      # Jekyll 4), so read them the same way jekyll-optional-front-matter does.
      base = static_file.instance_variable_get(:@base)
      dir  = static_file.instance_variable_get(:@dir)
      name = static_file.instance_variable_get(:@name)
      page = Jekyll::Page.new(site, base, dir, name)

      page.data["permalink"] = target_permalink(static_file)
      page
    end

    # Point a README Page's permalink at its directory
    def update_permalink(page)
      # If URL already ends with '/', it's a directory URL and should be used as-is
      url = page.url
      page.data["permalink"] = if append_html?
                                 target_permalink(page)
                               else
                                 url.end_with?("/") ? url : target_dir(page)
                               end
      # Page#url is memoized; drop it so it's rebuilt from the new permalink
      page.instance_variable_set(:@url, nil)
      page.url
    end

    # The directory a README should be the index for
    def target_dir(file)
      # For READMEs in .github or docs at root level, they should be the root index
      return "/" if special_readme?(file)

      File.join(File.dirname(file.url), "/")
    end

    def target_permalink(file)
      dir = target_dir(file)
      append_html? ? File.join(dir, "index.html") : dir
    end

    # Check if this is a README in a special directory (.github or docs)
    def special_readme?(file)
      path = readme_path(file)
      path =~ GITHUB_README_PATTERN || path =~ DOCS_README_PATTERN
    end

    # The file's path relative to the site source, with a leading slash.
    #
    # StaticFile#relative_path starts with "/", but Page#relative_path doesn't
    # on Jekyll 4 (or for root pages on Jekyll 3), so the priority patterns
    # never matched READMEs with front matter.
    def readme_path(file)
      path = file.relative_path
      path.start_with?("/") ? path : "/#{path}"
    end

    # Should the given readme be the containing directory's index?
    def should_be_index?(readme)
      return false unless readme

      !dir_has_index? target_dir(readme)
    end

    # Does the given directory have an index?
    #
    # relative_path - the directory path relative to the site root
    def dir_has_index?(relative_path)
      relative_path = File.join(relative_path, "/") unless relative_path.end_with?("/")
      index_dirs.include?(relative_path.downcase)
    end

    # The (downcased) directories that already have an index page or file.
    # Built once per generate instead of scanning every file for every README.
    def index_dirs
      @index_dirs ||= Set.new.tap do |dirs|
        site.pages.each { |page| add_index_dir(page.url, dirs) }
        site.static_files.each { |file| add_index_dir(file.url, dirs) }
      end
    end

    def add_index_dir(url, dirs = index_dirs)
      match = INDEX_URL_REGEX.match(url)
      dirs << match[1].downcase if match
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

    def append_html?
      option(APPEND_HTML_KEY) == true
    end

    # Helper method to get the file path (URL or path) for a file object
    def file_path(file)
      file.respond_to?(:url) ? file.url : "/" + file.path
    end
  end
end
