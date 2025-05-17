# Contributing to Flutter MCP

Thank you for considering contributing to Flutter MCP! This document outlines the process for contributing to the project.

## Code of Conduct

This project and everyone participating in it is governed by the [Flutter MCP Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

**Before Submitting A Bug Report:**

* Check the [issues](https://github.com/your-org/flutter_mcp/issues) to see if the problem has already been reported.
* Ensure you're using the latest version of Flutter MCP.
* Check if the problem is related to your Flutter or Dart environment.

**How Do I Submit A Good Bug Report?**

Bugs are tracked as [GitHub issues](https://github.com/your-org/flutter_mcp/issues). Create an issue and provide the following information:

* Use a clear and descriptive title.
* Describe the exact steps to reproduce the problem.
* Provide specific examples to demonstrate the steps.
* Describe the behavior you observed after following the steps.
* Explain which behavior you expected to see instead and why.
* Include screenshots or animated GIFs if possible.
* Include details about your environment (OS, Flutter version, etc.).
* Include any relevant code snippets or error messages.

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion, including completely new features and minor improvements to existing functionality.

**Before Submitting An Enhancement Suggestion:**

* Check the [issues](https://github.com/your-org/flutter_mcp/issues) to see if the enhancement has already been suggested.
* Check if the enhancement is compatible with the project's goals.

**How Do I Submit A Good Enhancement Suggestion?**

Enhancement suggestions are tracked as [GitHub issues](https://github.com/your-org/flutter_mcp/issues). Create an issue and provide the following information:

* Use a clear and descriptive title.
* Provide a detailed description of the suggested enhancement.
* Explain why this enhancement would be useful to most Flutter MCP users.
* Provide specific examples to demonstrate the enhancement.
* List some other applications where this enhancement exists, if applicable.
* Include any relevant code snippets or mockups.

### Pull Requests

The process described here has several goals:

* Maintain Flutter MCP's quality
* Fix problems that are important to users
* Engage the community in working toward the best possible Flutter MCP
* Enable a sustainable system for Flutter MCP's maintainers to review contributions

Please follow these steps to have your contribution considered by the maintainers:

1. Follow all instructions in the [pull request template](PULL_REQUEST_TEMPLATE.md).
2. Follow the [styleguides](#styleguides).
3. After you submit your pull request, verify that all [status checks](https://help.github.com/articles/about-status-checks/) are passing.

While the prerequisites above must be satisfied prior to having your pull request reviewed, the reviewer(s) may ask you to complete additional design work, tests, or other changes before your pull request can be ultimately accepted.

## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* Consider starting the commit message with an applicable emoji:
    * 🎨 `:art:` when improving the format/structure of the code
    * 🐎 `:racehorse:` when improving performance
    * 🚱 `:non-potable_water:` when plugging memory leaks
    * 📝 `:memo:` when writing docs
    * 🐛 `:bug:` when fixing a bug
    * 🔥 `:fire:` when removing code or files
    * 💚 `:green_heart:` when fixing the CI build
    * ✅ `:white_check_mark:` when adding tests
    * 🔒 `:lock:` when dealing with security
    * ⬆️ `:arrow_up:` when upgrading dependencies
    * ⬇️ `:arrow_down:` when downgrading dependencies

### Dart Styleguide

All Dart code should adhere to the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and pass the Flutter analyzer.

* Prefer using `final` or `const` over `var` when possible.
* Use meaningful variable names.
* Document all public APIs with dartdoc comments.
* Follow the [Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) for Flutter-specific code.

### Documentation Styleguide

* Use [Markdown](https://daringfireball.net/projects/markdown) for documentation.
* Document all public APIs with dartdoc comments.
* Include examples in documentation when possible.
* Keep documentation up to date with code changes.

## Additional Notes

### Issue and Pull Request Labels

This section lists the labels we use to help us track and manage issues and pull requests.

* `bug` - Issues that are bugs.
* `documentation` - Issues or PRs related to documentation.
* `enhancement` - Issues that are feature requests or PRs that implement features.
* `good first issue` - Issues that are good for newcomers.
* `help wanted` - Issues that need assistance from the community.
* `question` - Issues that are questions or need more information.
* `wontfix` - Issues that will not be worked on.

## Thank You!

Your contributions to open source, large or small, make great projects like this possible. Thank you for taking the time to contribute.
