# Changelog

## 0.5.1

Maintenance release: no runtime behavior changes.

### Documentation

- Add a gemspec description and RubyGems metadata (homepage, source code,
  bug tracker, and changelog links), and lead the README with the same
  one-line description (#69)

## 0.5.0

### Bug fixes

- Apply README precedence (`.github` > root > `docs`) to READMEs with front
  matter, and serve the winner at `/` (#66)
- Don't create a second `/` page from a static `.github/README.md` when the
  site already has an index (#66)
- Fix a double slash in the root README permalink (#65)

### Changes

- Stop adding methods to Jekyll's `StaticFile` and `Page` classes; the helpers
  now live in the generator (#66)

### Dependencies

- `kramdown-parser-gfm` is now a development dependency only. Jekyll 4 and
  `github-pages` already provide it; standalone Jekyll 3 sites that render
  GFM need it in their own Gemfile (#66)
- Declare `required_ruby_version >= 3.0` (#54)

### Infrastructure

- Bump `github/codeql-action` (#55, #59, #63, #64, #67)

## 0.4.0

### Features

- Support READMEs in `.github/` and `docs/` as the site index, following
  GitHub's precedence (`.github` > root > `docs`) (#48)

### Bug fixes

- Fix a bug where a README with front matter in a nested directory was moved
  to its parent directory (#43)

### Dependencies

- Constrain gemspec dependencies to their latest compatible versions (#45)

### Infrastructure

- Modernize CI — test Ruby 3.3 & 4.0 against Jekyll 3.x & 4.x (#52)
- Migrate CI from Travis to GitHub Actions; add CodeQL analysis
- Enable Dependabot for GitHub Actions; bump `actions/checkout` and
  `github/codeql-action` (#49, #50, #51)
- Stop tracking the vendored `vendor/` directory
