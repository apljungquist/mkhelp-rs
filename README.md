# MkHelp

_Support for docstrings in makefiles_

---

Sometimes it is convenient to use a makefile as interface to development workflows.
The recipes are flexible, can depend on other targets and `make` provides tab completion.

Once set up it could look something like

```console
$ make
Verbs:
 help: Print help message

Checks:
    check_all: Run all checks that have not yet passed
 check_format: Check format
   check_lint: Check lint
   check_docs: Check that documentation can be built
  check_tests: Check that unit tests pass

Fixes:
 fix_format: Fix format
 fix_lint: Fix lint
```
