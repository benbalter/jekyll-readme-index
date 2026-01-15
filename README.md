# Jekyll Readme Index

A Jekyll plugin to render a project's README as the site's index.

[![CI](https://github.com/benbalter/jekyll-readme-index/actions/workflows/ci.yml/badge.svg)](https://github.com/benbalter/jekyll-readme-index/actions/workflows/ci.yml)

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
  with_frontmatter: false
  readme_pattern:   nil
```

### GitHub-style README locations

Following [GitHub's README conventions](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes), this plugin supports READMEs in multiple locations:

- `.github/README.md` - Hidden in the `.github` directory
- `README.md` - Root directory (traditional location)
- `docs/README.md` - In the `docs` directory

If multiple READMEs exist, they are prioritized in the order above (matching GitHub's behavior). For example, if both `.github/README.md` and `README.md` exist, the `.github/README.md` will be used as the site index.

**Note:** To use `.github/README.md`, you must add `.github` to your Jekyll `include` configuration:

```yml
include:
  - .github
```

### Custom README pattern

You can override the default README detection pattern by setting the `readme_pattern` configuration option:

```yml
readme_index:
  readme_pattern: "/custom-readme\\.md$"
```

This allows you to use a different filename or pattern for your README files. The pattern is treated as a case-insensitive regular expression.

### Removing originals

By default the original README markdown files will be included as static pages in the output. To remove them from the output, set the `remove_originals` key to `true`.

### Disabling

Even if the plugin is enabled (e.g., via the `:jekyll_plugins` group in your Gemfile) you can disable it by setting the `enabled` key to `false`.
