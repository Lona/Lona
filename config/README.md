# Configuration

This directory contains linter, formatter, and CI configuration files.

## CI

### Configuration

To modify the DangerFile:

- Install Danger Swift: `brew install danger/tap/danger-swift`.
- Edit the DangerFile: `danger-swift edit`.

### Testing the local DangerFile with a PR

- Create a GitHub token: https://github.com/settings/tokens/new
- Run `DANGER_GITHUB_API_TOKEN=xxx danger-swift pr https://github.com/airbnb/Lona/pull/PR_NUMBER --dangerfile=config/Dangerfile.swift` at the root
