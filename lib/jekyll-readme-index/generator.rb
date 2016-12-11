module JekyllReadmeIndex
  class Generator < Jekyll::Generator
    README_REGEX = %r!^/readme(\.[^.]+)?$!i
    INDEX_REGEX = %r!^/($|index\.html?$)!i

    attr_accessor :site

    safe true
    priority :low

    def initialize(site)
      @site = site
    end

    def generate(site)
      @site = site

      return if index? || readme.nil?
      site.pages << page
    end

    private

    def readme
      site.static_files.find { |file| file.relative_path =~ README_REGEX }
    end

    def index?
      (site.pages + site.static_files).any? { |file| file.url =~ INDEX_REGEX }
    end

    def page
      base = readme.instance_variable_get("@base")
      dir  = readme.instance_variable_get("@dir")
      name = readme.instance_variable_get("@name")
      page = Jekyll::Page.new(site, base, dir, name)
      page.data["permalink"] = "/"
      page
    end
  end
end
