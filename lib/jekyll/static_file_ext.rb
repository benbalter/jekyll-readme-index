# frozen_string_literal: true

module Jekyll
  class StaticFile
    # Convert this static file to a Page
    def to_page
      page = Jekyll::Page.new(@site, @base, @dir, @name)
      page.data["permalink"] = File.dirname(url) + "/"
      page
    end
  end

  class Page
    def update_permalink
      # If URL already ends with '/', it's a directory URL and should be used as-is
      # Otherwise, extract the directory from the file URL
      target_dir = url.end_with?('/') ? url : File.dirname(url) + "/"
      
      data["permalink"] = target_dir
      @url = URL.new(
        :template     => template,
        :placeholders => url_placeholders,
        :permalink    => permalink
      ).to_s
    end
  end
end
