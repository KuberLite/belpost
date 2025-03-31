# Releasing a New Gem Version

This document describes the process for releasing a new version of the Belpost gem.

## Release Steps

1. Make sure all tests pass successfully:
   ```
   bundle exec rspec
   ```

2. Update the version number in `lib/belpost/version.rb`

3. Update CHANGELOG.md with descriptions of changes in the new version

4. Commit your changes:
   ```
   git add lib/belpost/version.rb CHANGELOG.md
   git commit -m "Release version X.Y.Z"
   ```

5. Create a tag for the new version:
   ```
   git tag -a vX.Y.Z -m "Version X.Y.Z"
   ```

6. Push the commit and tag to GitHub:
   ```
   git push origin master
   git push origin vX.Y.Z
   ```

7. GitHub Actions will automatically publish the gem to RubyGems.org when a new tag starting with 'v' is created.

## Setup

For automatic gem publication, you need to add the `RUBYGEMS_API_KEY` secret in your GitHub repository settings:

1. Create an API key on RubyGems.org (if not already created)
2. Go to your repository settings on GitHub: Settings > Secrets and variables > Actions
3. Add a new secret named `RUBYGEMS_API_KEY` with the value of your API key from RubyGems.org 