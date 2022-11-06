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
#
# * Macros (or _recursively expanded variables_)
# * Constants (or _simply expanded variables_)

CLEAN_DIR_TARGET = git clean -xdf $(@D); mkdir -p $(@D)


## Verbs
## =====
## This section contains targets that
##
## * May have side effect
## * Should not have side effects should not affect nouns

help:
	@python bin/print_makefile_help.py < $(MAKEFILE_LIST)

## Checks
## ------

## Run all checks that have not yet passed
check_all: check_format check_types check_lint check_dist check_docs check_diff check_tests check_tox
	rm $^

## _
check_format:
	isort --check setup.py src/ tests/
	black --check setup.py src/ tests/
	touch $@

## _
check_lint:
	pylint setup.py src/ tests/
	flake8 setup.py src/ tests/
	touch $@

# TODO: Consider moving into tox for cases where non-universal wheels are built for more than one target
## Check that distribution can be built and will render correctly on PyPi
check_dist: dist/_envoy;
	touch $@

## Check that documentation can be built
check_docs: build/docs/index.html
	touch $@

## Check that there are no untracked git changes
check_diff: bin/print_makefile_help.py constraints.txt
	git update-index -q --refresh
	git --no-pager diff --exit-code HEAD
	touch $@

# No coverage here to avoid race conditions?
## Check that unit tests pass
check_tests:
	pytest --durations=10 --doctest-modules src/mkhelp tests/
	touch $@

## Check that unit tests pass in multiple environments
check_tox:
	tox -e py38
	tox -e py311
	touch $@

# This target will use cache created by coverage report but not the other way around.
## _
check_types: reports/type_coverage/html/index.html
	mypy \
		--cobertura-xml-report=reports/type_coverage/ \
		--html-report=reports/type_coverage/html/ \
		--package mkhelp
	touch $@

## Fixes
## -----

## _
fix_format:
	isort setup.py src/ tests/
	black setup.py src/ tests/

## Nouns
## =====
## This section contains targets that
##
## * Should have no side effects
## * Must have no side effects on other nouns
## * Must not have any prerequisites that are verbs
## * Ordered first by specificity, second by name

bin/print_makefile_help.py:
	mkhelp print_script > $@

## Build this documentation
##
## If it runs slow, try removing the :code:`CLEAN_DIR_TARGET` line in the recipe.
build/docs/index.html: docs/makefile.rst
	$(CLEAN_DIR_TARGET)
	sphinx-build -b html docs $(@D)

constraints.txt: requirements/build.txt requirements/dev.txt requirements/run.txt
	pip-compile --allow-unsafe --output-file $@ --quiet --strip-extras $^

dist/_envoy:
	$(CLEAN_DIR_TARGET)
	python -m build --outdir $(@D) .
	twine check $(@D)/*

docs/makefile.rst:
	mkhelp print_docs Makefile rst > $@

reports/test_coverage/.coverage: $(wildcard .coverage.*)
	coverage combine --keep --data-file=$@ $^

reports/test_coverage/html/index.html: reports/test_coverage/.coverage
	coverage html --data-file=$< --directory=$(@D)

reports/test_coverage/coverage.xml: reports/test_coverage/.coverage
	coverage xml --data-file=$< -o $@

reports/type_coverage/html/index.html:
	$(CLEAN_DIR_TARGET)
	mypy \
		--html-report=$(@D) \
		bin/ \
		src/ \
		tests/
	touch $@

requirements/build.txt: pyproject.toml
	pilecap plumbing build-requirements . > $@

requirements/run.txt: setup.cfg
	pilecap plumbing run-requirements . > $@