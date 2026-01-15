# frozen_string_literal: true

module Jekyll
  class StaticFile
    # Convert this static file to a Page
    def to_page
      page = Jekyll::Page.new(@site, @base, @dir, @name)

      # For READMEs in .github or docs at root level, they should be the root index
      target_dir = if special_readme?
                     "/"
                   else
                     File.dirname(url) + "/"
                   end

      page.data["permalink"] = target_dir
      page
    end

    private

    # Check if this is a README in a special directory (.github or docs)
    def special_readme?
      relative_path =~ JekyllReadmeIndex::Generator::GITHUB_README_PATTERN ||
        relative_path =~ JekyllReadmeIndex::Generator::DOCS_README_PATTERN
    end
  end

  class Page
    def update_permalink
      # If URL already ends with '/', it's a directory URL and should be used as-is
      # Otherwise, extract the directory from the file URL
      target_dir = url.end_with?("/") ? url : File.dirname(url) + "/"

      data["permalink"] = target_dir
      @url = URL.new(
        :template     => template,
        :placeholders => url_placeholders,
        :permalink    => permalink
      ).to_s
    end
  end
end
