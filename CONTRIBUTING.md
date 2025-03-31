# Contributing Guide

## Development Environment Setup

1. Fork the repository and clone it:
   ```
   git clone https://github.com/YOUR_USERNAME/belpost.git
   cd belpost
   ```

2. Install dependencies:
   ```
   bundle install
   ```

3. Run tests to make sure everything works:
   ```
   bundle exec rspec
   ```

## Development Process

1. Create a new branch for your feature or fix:
   ```
   git checkout -b feature/your-feature-name
   ```

2. Make changes and add tests for new functionality.

3. Make sure all tests pass:
   ```
   bundle exec rspec
   ```

4. Update documentation if you've added new features or changed existing ones.

5. Commit your changes:
   ```
   git commit -am "Added new feature: XYZ"
   ```

6. Push your branch to GitHub:
   ```
   git push origin feature/your-feature-name
   ```

7. Create a Pull Request from your branch to the main repository.

## Code Conventions

- Follow the code style used in the project
- Write YARD format documentation for new classes and methods
- Always add tests for new functionality
- Update CHANGELOG.md with descriptions of your changes in the [Unreleased] section

## Review Process

After creating a Pull Request:
1. Wait for all CI checks to pass
2. Respond to comments and make necessary corrections
3. After approval, your Pull Request will be merged into the main branch

Thank you for your contribution! 