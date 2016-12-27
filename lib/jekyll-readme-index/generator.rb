module JekyllReadmeIndex
  class Generator < Jekyll::Generator
    README_REGEX = %r!^/readme(\.[^.]+)?$!i
    READMES_REGEX = %r!/readme(\.[^.]+)?$!i
    INDEX_MATCH_PATTERN = "($|index\.(html?|xhtml|xml)$)".freeze

    attr_accessor :site

    safe true
    priority :low

    def initialize(site)
      @site = site
    end

    def generate(site)
      @site = site

      readmes.each do |readme|
        next if relative_index?(readme)
        site.pages << relative_page(readme)
      end
    end

    private

    def readme
      site.static_files.find { |file| file.relative_path =~ README_REGEX }
    end

    def index?
      relative_index?(readme)
    end

    def page
      relative_page(readme)
    end

    def readmes
      site.static_files.select { |file| file.relative_path =~ READMES_REGEX }
    end

    def relative_index?(readme)
      if readme
        name = readme.instance_variable_get("@name")
        relative_path = readme.relative_path.sub(%r!#{name}$!, "")
      else
        relative_path = "/"
      end
      index_regex = %r!^#{relative_path}#{INDEX_MATCH_PATTERN}!i
      (site.pages + site.static_files).any? { |file| file.url =~ index_regex }
    end

    def relative_page(readme)
      return unless readme
      base = readme.instance_variable_get("@base")
      dir  = readme.instance_variable_get("@dir")
      name = readme.instance_variable_get("@name")
      relative_path = readme.relative_path.sub(%r!#{name}$!, "")
      page = Jekyll::Page.new(site, base, dir, name)
      page.data["permalink"] = relative_path
      page
    end
  end
end
