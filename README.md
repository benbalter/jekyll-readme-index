# Jekyll Readme Index

A Jekyll plugin to render a project's README as the site's index.

[![Build Status](https://travis-ci.org/benbalter/jekyll-readme-index.svg?branch=master)](https://travis-ci.org/benbalter/jekyll-readme-index)

## What it does

Let's say you have a GitHub repository with a `README.md` file, that you'd like to use as the index (main page) for a GitHub Pages site. You could rename the file to `index.md`, but then it wouldn't render on GitHub.com. You could add YAML front matter with `permalink: /` to the README, but why force a human to do what Jekyll can automate?

If you have a readme file, and your site doesn't otherwise have an index file, this plugin instructs Jekyll to use the readme as the site's index. That's it. No more, no less.

## Usage

1. Add the following to your Gemfile

  ```ruby
  gem "jekyll-readme-index"
  ```

2. Add the follow to your site's config

  ```yml
  plugins:
    - jekyll-readme-index
  ```
  Note: If you are using a Jekyll version less than 3.5.0, use the `gems` key instead of `plugins`.

## Configuration

Configuration options are optional are placed in `_config.yml` under the `readme_index` key. They default to:

```yml
readme_index:
  enabled:          true
  remove_originals: false
```

### Removing originals

By default the original README markdown files will be included as static pages in the output. To remove them from the output, set the `remove_originals` key to `true`.

### Disabling

Even if the plugin is enabled (e.g., via the `:jekyll_plugins` group in your Gemfile) you can disable it by setting the `enabled` key to `false`.
