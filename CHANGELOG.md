# Changelog

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
