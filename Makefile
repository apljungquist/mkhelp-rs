# Config
# ======
# This section contains various special targets and variables that affect the behavior
# of make.

.DEFAULT_GOAL=help

# Delete targets that fail (to prevent subsequent attempts to make incorrectly
# assuming the target is up to date). Especially useful with the envoy pattern.
.DELETE_ON_ERROR: ;

SHELL=/bin/bash


# Definitions
# ===========
# This section contains reusable functionality such as
# * Macros (or _recursively expanded variables_)
# * Constants (or _simply expanded variables_)

CLEAN_DIR_TARGET = git clean -xdf $(@D); mkdir -p $(@D)


## Verbs
## =====
# This section contains targets that
# * May have side effect
# * Should not have side effects should not affect nouns

## Print help message
help:
	@mkhelp $(firstword $(MAKEFILE_LIST))

## Checks
## ------

## Run all checks
##
## Can be parallelized like `make -j check_all`.
check_all: check_format check_lint check_docs check_tests
	rm $^

## _
check_format:
	cargo fmt --check

## _
check_lint:
	cargo clippy \
		--all-targets \
		--no-deps \
		-- \
		-Dwarnings


## Check that documentation can be built
check_docs:
	cargo doc --no-deps

## Check that unit tests pass
check_tests:
	cargo test

## Fixes
## -----

## _
fix_format:
	find src \
	| grep -E '.*\.rs' \
	| xargs rustfmt --config imports_granularity=Crate --config group_imports=StdExternalCrate --edition 2021
	cargo fmt

## _
fix_lint:
	cargo clippy --fix


## Nouns
## =====
# This section contains targets that
# * Should have no side effects
# * Must have no side effects on other nouns
# * Must not have any prerequisites that are verbs
# * Ordered first by specificity, second by name
