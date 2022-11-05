# Makefile Help

_Support for docstrings in makefiles_

Sometimes it is convenient to use a makefile as interface to development workflows.
The recipes are flexible, can depend on other targets and `make` provides tab completion.

With the script provided by this package it is easy to also get a help message describing important make targets.
Look to the `.DEFAULT_GOAL` and `bin/print_makefile_help.py` targets in the makefile to see how to set it up.
Once set up it could look something like

```text
$ make
Checks:
             check_all: Run all checks that have not yet passed
          check_format: Check format
            check_lint: Check lint
            check_dist: Check that distribution can be built and will render correctly on PyPi
            check_docs: Check that documentation can be built
            check_diff: Check that there are no untracked git changes
           check_tests: Check that unit tests pass
           check_types: Check types

Fixes:
            fix_format: Fix format

Nouns
 build/docs/index.html: Build this documentation
```


On additional feature of this package is to export the docstrings in the makefile to other formats allowing them to be included in documentation.
Look to the `build/docs/index.html` target in the makefile to see how to set it up.
Once set up it could look something like the makefile page in the docs of this project.