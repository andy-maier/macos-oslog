# Makefile for the macos-oslog project.
#
# Supported OS platforms for this Makefile:
#     Linux (any distro)
#     OS-X
#     Windows with UNIX-like env such as CygWin (with a UNIX-like shell and
#       Python in the UNIX-like env)
#     native Windows (with the native Windows command processor and Python in
#       Windows)
#
# Prerequisites for running this Makefile:
#   These commands are used on all supported OS platforms. On native Windows,
#   they may be provided by UNIX-like environments such as CygWin:
#     make (GNU make)
#     python (This Makefile uses the active Python environment, virtual Python
#       environments are supported)
#     pip (in the active Python environment)
#     twine (in the active Python environment)
#   These additional commands are used on Linux, OS-X and on Windows with
#   UNIX-like environments:
#     uname
#     rm, find, xargs, cp
#   These additional commands are used on native Windows:
#     del, copy, rmdir

# No built-in rules needed:
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

# Python / Pip commands
ifndef PYTHON_CMD
  PYTHON_CMD := python
endif
ifndef PIP_CMD
  PIP_CMD := pip
endif

# Pip options that are always to be used
pip_opts := --disable-pip-version-check

# Package level
ifndef PACKAGE_LEVEL
  PACKAGE_LEVEL := latest
endif
ifeq ($(PACKAGE_LEVEL),minimum)
  pip_level_opts := -c minimum-constraints.txt
else
  ifeq ($(PACKAGE_LEVEL),latest)
    pip_level_opts := --upgrade --upgrade-strategy eager
  else
    $(error Error: Invalid value for PACKAGE_LEVEL variable: $(PACKAGE_LEVEL))
  endif
endif

# Make variables are case sensitive and some native Windows environments have
# ComSpec set instead of COMSPEC.
ifndef COMSPEC
  ifdef ComSpec
    COMSPEC = $(ComSpec)
  endif
endif

# Determine OS platform make runs on.
#
# The PLATFORM variable is set to one of:
# * Darwin: OS-X / macOS
#
# Values: Linux, Darwin
PLATFORM := $(shell uname -s)
PIP_CMD_MOD := $(PIP_CMD)

RM_FUNC = rm -f $(1)
RM_R_FUNC = find . -type f -name '$(1)' -delete
RMDIR_FUNC = rm -rf $(1)
RMDIR_R_FUNC = find . -type d -name '$(1)' | xargs -n 1 rm -rf
CP_FUNC = cp -r $(1) $(2)
ENV = env | sort
WHICH = which

# Name of this project
project_name := macos-oslog

# Name of this Pypi package
pypi_name := macos-oslog

# Base name of distribution source archive (using dashes)
sdist_name := macos-oslog

# Base name of distribution binary archive (using underscores)
bdist_name := macos_oslog

# Name of this Python module
module_name := macos_oslog

# Determine if coverage details report generated
# The variable can be passed in as either an environment variable or
# command line variable. When set, generates a set of reports of the
# Python source files showing line by line coverage.
ifdef COVERAGE_REPORT
  coverage_report := --cov-report=annotate --cov-report=html
else
  coverage_report :=
endif

# Directory for coverage html output. Must be in sync with the one in .coveragerc.
coverage_html_dir := coverage_html

# Package version (full version, including any pre-release suffixes, e.g. "0.1.0.dev1").
# Note: The package version is defined in _version.py.
package_version := $(shell $(PYTHON_CMD) setup.py --version)

# Python versions and bit size
python_full_version := $(shell $(PYTHON_CMD) -c "import sys; sys.stdout.write('{v[0]}.{v[1]}.{v[2]}'.format(v=sys.version_info))")
python_mn_version := $(shell $(PYTHON_CMD) -c "import sys; sys.stdout.write('py{v[0]}{v[1]}'.format(v=sys.version_info))")
python_m_version := $(shell $(PYTHON_CMD) -c "import sys; sys.stdout.write('{v[0]}'.format(v=sys.version_info))")
python_bitsize := $(shell $(PYTHON_CMD) -c "import sys,ctypes; sys.stdout.write('{s}'.format(s=ctypes.sizeof(ctypes.c_void_p)*8))")

# Directory for the generated distribution files
dist_dir := dist

# Distribution archives
python_cp_version := $(shell $(PYTHON_CMD) -c "import sys; sys.stdout.write('cp{v[0]}{v[1]}'.format(v=sys.version_info))")
bdist_file = $(dist_dir)/$(bdist_name)-$(package_version)-$(python_cp_version)-$(python_cp_version)-macosx_11_0_x86_64.whl
sdist_file = $(dist_dir)/$(sdist_name)-$(package_version).tar.gz

# C source files in the packages
package_c_files := $(wildcard src/*.c)

# Directory for generated API documentation
doc_build_dir := build_doc

# Directory where Sphinx conf.py and the docs source files is located
doc_dir := docs

# Paper format for the Sphinx LaTex/PDF builder.
# Valid values: a4, letter
doc_paper_format := a4

# Documentation generator command
doc_cmd := sphinx-build
doc_opts := -v -d $(doc_build_dir)/doctrees -c $(doc_dir) -D latex_elements.papersize=$(doc_paper_format) .

# Dependents for Sphinx documentation build
doc_dependent_files := \
    $(doc_dir)/conf.py \
    $(wildcard $(doc_dir)/*.rst) \
		$(package_c_files) \

# PyLint config file
pylint_rc_file := pylintrc

# PyLint additional options
pylint_opts := --disable=fixme

# Flake8 config file
flake8_rc_file := .flake8

# Test root directory
test_dir := tests

# Python source files to be checked by PyLint and Flake8
py_src_files := \
    setup.py \
    $(wildcard $(test_dir)/*.py) \
    $(wildcard $(test_dir)/*/*.py) \
    $(wildcard $(test_dir)/*/*/*.py) \
    $(wildcard $(test_dir)/*/*/*/*.py) \

ifdef TESTCASES
  pytest_opts := $(TESTOPTS) -k $(TESTCASES)
else
  pytest_opts := $(TESTOPTS)
endif
pytest_warning_opts := -W default -W ignore::PendingDeprecationWarning -W ignore::ResourceWarning
pytest_cov_opts := --cov src $(coverage_report) --cov-config .coveragerc

# Files to be put into distribution archive.
# This is also used for 'include' statements in MANIFEST.in.
# Wildcards can be used directly (i.e. without wildcard function).
dist_included_files := \
    LICENSE \
    README.rst \
    INSTALL.md \
    requirements.txt \
    setup.py \

.PHONY: help
help:
	@echo "Makefile for $(project_name) project version: $(package_version)"
	@echo ""
	@echo "Make targets:"
	@echo "  develop    - Set up development of $(project_name) project"
	@echo "  build      - Build the distribution archive files in: $(dist_dir)"
	@echo "  install    - Install the source archive: $(sdist_file)"
	@echo "  builddoc   - Build documentation in: $(doc_build_dir)"
	@echo "  check      - Run Flake8 on Python sources"
	@echo "  pylint     - Run PyLint on Python sources"
	@echo "  test       - Run unit tests"
	@echo "  all        - Do all of the above"
	@echo "  upload     - build + upload the package to PyPI"
	@echo "  clean      - Remove any temporary files"
	@echo "  clobber    - Remove everything created to ensure clean start"
	@echo "  pip_list   - Display the installed Python packages as seen by make"
	@echo "  platform   - Display the information about the platform as seen by make"
	@echo "  env        - Display the environment as seen by make"
	@echo ""
	@echo "Environment variables:"
	@echo "  COVERAGE_REPORT - When non-empty, the 'test' target creates a coverage report as"
	@echo "      annotated html files showing lines covered and missed, in the directory:"
	@echo "      $(coverage_html_dir)"
	@echo "      Optional, defaults to no such coverage report."
	@echo "  TESTCASES - When non-empty, 'test' target runs only the specified test cases. The"
	@echo "      value is used for the -k option of pytest (see 'pytest --help')."
	@echo "      Optional, defaults to running all tests."
	@echo "  TESTOPTS - Optional: Additional options for py.tests (see 'pytest --help')."
	@echo "  PACKAGE_LEVEL - Package level to be used for installing dependent Python"
	@echo "      packages in 'install' and 'develop' targets:"
	@echo "        latest - Latest package versions available on Pypi"
	@echo "        minimum - A minimum version as defined in minimum-constraints.txt"
	@echo "      Optional, defaults to 'latest'."
	@echo "  PYTHON_CMD - Python command to be used. Useful for Python 3 in some envs."
	@echo "      Optional, defaults to 'python'."
	@echo "  PIP_CMD - Pip command to be used. Useful for Python 3 in some envs."
	@echo "      Optional, defaults to 'pip'."

.PHONY: platform
platform:
	@echo "Makefile: Platform related information as seen by make:"
	@echo "Platform: $(PLATFORM)"
	@echo "Shell used for commands: $(SHELL)"
	@echo "Shell flags: $(.SHELLFLAGS)"
	@echo "Make command location: $(MAKE)"
	@echo "Make version: $(MAKE_VERSION)"
	@echo "Python command name: $(PYTHON_CMD)"
	@echo "Python command location: $(shell $(WHICH) $(PYTHON_CMD))"
	@echo "Python version: $(python_full_version)"
	@echo "Python bit size: $(python_bitsize)"
	@echo "Pip command name: $(PIP_CMD)"
	@echo "Pip command location: $(shell $(WHICH) $(PIP_CMD))"
	@echo "Pip command for modifications: $(PIP_CMD_MOD)"
	@echo "Package $(pypi_name) version: $(package_version)"
	@echo "Package $(pypi_name) installation: $(shell $(PIP_CMD) $(pip_opts) show $(pypi_name) | grep Location)"

.PHONY: pip_list
pip_list:
	@echo "Makefile: Installed Python packages:"
	$(PIP_CMD) $(pip_opts) list

.PHONY: env
env:
	@echo "Makefile: Environment as seen by make:"
	$(ENV)

.PHONY: _check_version
_check_version:
ifeq (,$(package_version))
	$(error Package version could not be determined)
endif

.PHONY: _check_installed
_check_installed:
	@echo "Makefile: Verifying installation of module $(module_name)"
	$(PYTHON_CMD) -c "import $(module_name)"
	@echo "Makefile: Done verifying installation of package $(module_name)"

pip_upgrade_$(python_mn_version).done: Makefile
	@echo "Makefile: Installing/upgrading Pip (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	-$(call RM_FUNC,$@)
	bash -c 'pv=$$($(PIP_CMD) --version); if [[ $$pv =~ (^pip [1-8]\..*) ]]; then $(PYTHON_CMD) -m pip $(pip_opts) install pip==9.0.1; fi'
	$(PYTHON_CMD) -m pip $(pip_opts) install $(pip_level_opts) pip
	echo "done" >$@
	@echo "Makefile: Done installing/upgrading Pip"

install_basic_$(python_mn_version).done: Makefile pip_upgrade_$(python_mn_version).done
	@echo "Makefile: Installing/upgrading basic Python packages (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	-$(call RM_FUNC,$@)
	$(PIP_CMD_MOD) $(pip_opts) install $(pip_level_opts) setuptools wheel
	echo "done" >$@
	@echo "Makefile: Done installing/upgrading basic Python packages"

install_reqs_$(python_mn_version).done: Makefile install_basic_$(python_mn_version).done requirements.txt
	@echo "Makefile: Installing Python installation prerequisites (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	-$(call RM_FUNC,$@)
	$(PIP_CMD_MOD) $(pip_opts) install $(pip_level_opts) -r requirements.txt
	echo "done" >$@
	@echo "Makefile: Done installing Python installation prerequisites"

develop_reqs_$(python_mn_version).done: install_basic_$(python_mn_version).done dev-requirements.txt
	@echo "Makefile: Installing development requirements (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	-$(call RM_FUNC,$@)
	$(PIP_CMD_MOD) $(pip_opts) install $(pip_level_opts) -r dev-requirements.txt
	echo "done" >$@
	@echo "Makefile: Done installing development requirements"

.PHONY: install
install: install_$(python_mn_version).done
	@echo "Makefile: Target $@ done."

install_$(python_mn_version).done: Makefile install_reqs_$(python_mn_version).done setup.py
	@echo "Makefile: Installing package $(pypi_name) (with PACKAGE_LEVEL=$(PACKAGE_LEVEL))"
	$(PIP_CMD_MOD) $(pip_opts) install .
	@echo "Makefile: Done installing package $(pypi_name)"
	@echo "Makefile: Verifying installation of module $(module_name)"
	$(PYTHON_CMD) -c "import $(module_name)"
	@echo "Makefile: Done verifying installation of module $(module_name)"
	echo "done" >$@

.PHONY: develop
develop: develop_reqs_$(python_mn_version).done Makefile
	@echo "Makefile: Target $@ done."

.PHONY: build
build: _check_version $(bdist_file) $(sdist_file)
	@echo "Makefile: Target $@ done."

.PHONY: builddoc
builddoc: html
	@echo "Makefile: Target $@ done."

.PHONY: check
check: flake8_$(python_mn_version).done safety_$(python_mn_version).done
	@echo "Makefile: Target $@ done."

.PHONY: pylint
pylint: pylint_$(python_mn_version).done
	@echo "Makefile: Target $@ done."

.PHONY: all
all: develop build install builddoc check pylint test
	@echo "Makefile: Target $@ done."

.PHONY: clobber
clobber: clean
	@echo "Makefile: Removing everything for a fresh start"
	-$(call RM_FUNC,*.done $(bdist_file) $(sdist_file) $(dist_dir)/$(bdist_name)-$(package_version)*.egg src/*cover)
	-$(call RMDIR_FUNC,$(doc_build_dir) .tox $(coverage_html_dir) $(bdist_name).egg-info)
	@echo "Makefile: Done removing everything for a fresh start"
	@echo "Makefile: Target $@ done."

.PHONY: clean
clean:
	@echo "Makefile: Removing temporary build products"
	-$(call RM_R_FUNC,*.pyc)
	-$(call RMDIR_R_FUNC,__pycache__)
	-$(call RM_R_FUNC,*~)
	-$(call RM_R_FUNC,.*~)
	-$(call RM_FUNC,MANIFEST .coverage)
	-$(call RMDIR_FUNC,build .cache)
	@echo "Makefile: Done removing temporary build products"
	@echo "Makefile: Target $@ done."

.PHONY: upload
upload: _check_version $(sdist_file)
	@echo "Makefile: Checking files before uploading to PyPI"
	twine check $(sdist_file)
	@echo "Makefile: Uploading to PyPI: $(pypi_name) $(package_version) (source archive)"
	twine upload $(sdist_file)
	@echo "Makefile: Done uploading to PyPI"
	@echo "Makefile: Target $@ done."

.PHONY: html
html: develop_reqs_$(python_mn_version).done $(doc_build_dir)/html/docs/index.html
	@echo "Makefile: Target $@ done."

$(doc_build_dir)/html/docs/index.html: Makefile install_$(python_mn_version).done $(doc_dependent_files)
	@echo "Makefile: Creating the documentation as HTML pages"
	-$(call RM_FUNC,$@)
	$(doc_cmd) -b html $(doc_opts) $(doc_build_dir)/html
	@echo "Makefile: Done creating the documentation as HTML pages; top level file: $@"

.PHONY: pdf
pdf: develop_reqs_$(python_mn_version).done Makefile install_$(python_mn_version).done $(doc_dependent_files)
	@echo "Makefile: Creating the documentation as PDF file"
	-$(call RM_FUNC,$@)
	$(doc_cmd) -b latex $(doc_opts) $(doc_build_dir)/pdf
	@echo "Makefile: Running LaTeX files through pdflatex..."
	$(MAKE) -C $(doc_build_dir)/pdf all-pdf
	@echo "Makefile: Done creating the documentation as PDF file in: $(doc_build_dir)/pdf/"
	@echo "Makefile: Target $@ done."

.PHONY: man
man: develop_reqs_$(python_mn_version).done Makefile install_$(python_mn_version).done $(doc_dependent_files)
	@echo "Makefile: Creating the documentation as man pages"
	-$(call RM_FUNC,$@)
	$(doc_cmd) -b man $(doc_opts) $(doc_build_dir)/man
	@echo "Makefile: Done creating the documentation as man pages in: $(doc_build_dir)/man/"
	@echo "Makefile: Target $@ done."

.PHONY: docchanges
docchanges: develop_reqs_$(python_mn_version).done
	@echo "Makefile: Creating the doc changes overview file"
	$(doc_cmd) -b changes $(doc_opts) $(doc_build_dir)/changes
	@echo
	@echo "Makefile: Done creating the doc changes overview file in: $(doc_build_dir)/changes/"
	@echo "Makefile: Target $@ done."

.PHONY: doclinkcheck
doclinkcheck: develop_reqs_$(python_mn_version).done
	@echo "Makefile: Creating the doc link errors file"
	$(doc_cmd) -b linkcheck $(doc_opts) $(doc_build_dir)/linkcheck
	@echo
	@echo "Makefile: Done creating the doc link errors file: $(doc_build_dir)/linkcheck/output.txt"
	@echo "Makefile: Target $@ done."

.PHONY: doccoverage
doccoverage: develop_reqs_$(python_mn_version).done
	@echo "Makefile: Creating the doc coverage results file"
	$(doc_cmd) -b coverage $(doc_opts) $(doc_build_dir)/coverage
	@echo "Makefile: Done creating the doc coverage results file: $(doc_build_dir)/coverage/python.txt"
	@echo "Makefile: Target $@ done."

# Note: distutils depends on the right files specified in MANIFEST.in, even when
# they are already specified e.g. in 'package_data' in setup.py.
# We generate the MANIFEST.in file automatically, to have a single point of
# control (this Makefile) for what gets into the distribution archive.
MANIFEST.in: Makefile $(dist_included_files)
	@echo "Makefile: Creating the manifest input file"
	echo "# MANIFEST.in file generated by Makefile - DO NOT EDIT!!" >$@
	echo "$(dist_included_files)" | xargs -n 1 echo include >>$@
	echo "recursive-include $(test_dir) *" >>$@
	echo "recursive-exclude $(test_dir) *.pyc" >>$@
	@echo "Makefile: Done creating the manifest input file: $@"

# Distribution archives.
# Note: Deleting build is a safeguard against picking up partial build products
# which can lead to incorrect hashbangs in scripts in wheel archives.
#	$(PYTHON_CMD) setup.py sdist -d $(dist_dir) bdist_wheel -d $(dist_dir) --universal
$(bdist_file) $(sdist_file): develop_reqs_$(python_mn_version).done setup.py MANIFEST.in $(dist_included_files)
	@echo "Makefile: Creating the distribution archive files"
	-$(call RMDIR_FUNC,build $(bdist_name).egg-info)
	$(PYTHON_CMD) -m build --outdir $(dist_dir)
	@echo "Makefile: Done creating the distribution archive files: $(bdist_file) $(sdist_file)"

pylint_$(python_mn_version).done: develop_reqs_$(python_mn_version).done Makefile $(pylint_rc_file) $(py_src_files)
ifeq ($(python_mn_version),py35)
	@echo "makefile: Warning: Skipping Pylint on Python $(python_version)" >&2
else
	@echo "Makefile: Running Pylint"
	-$(call RM_FUNC,$@)
	pylint --version
	pylint $(pylint_opts) --rcfile=$(pylint_rc_file) $(py_src_files)
	echo "done" >$@
	@echo "Makefile: Done running Pylint"
endif

flake8_$(python_mn_version).done: develop_reqs_$(python_mn_version).done Makefile $(flake8_rc_file) $(py_src_files)
	@echo "Makefile: Running Flake8"
	-$(call RM_FUNC,$@)
	flake8 --version
	flake8 --statistics --config=$(flake8_rc_file) --filename='*' $(py_src_files)
	echo "done" >$@
	@echo "Makefile: Done running Flake8"

safety_$(python_mn_version).done: develop_reqs_$(python_mn_version).done Makefile minimum-constraints.txt
	@echo "Makefile: Running pyup.io safety check"
	-$(call RM_FUNC,$@)
	-safety check -r minimum-constraints.txt --full-report
	echo "done" >$@
	@echo "Makefile: Done running pyup.io safety check"

.PHONY: test
test: develop_reqs_$(python_mn_version).done Makefile
	@echo "Makefile: Running unit tests"
	py.test --color=yes $(pytest_cov_opts) $(pytest_warning_opts) $(pytest_opts) $(test_dir)/unittest -s
	@echo "Makefile: Done running unit tests"
