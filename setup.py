#!/usr/bin/env python
"""
Python setup script for the macos-oslog project.
"""

import sys
import os
import re
# setuptools needs to be imported before distutils in order to work.
import setuptools
from distutils import log  # pylint: disable=wrong-import-order
from distutils.core import Extension  # pylint: disable=wrong-import-order


def get_version(version_file):
    """
    Parse the specified version file (C format) and return the value of the
    __version__ global variable that is set in the version file.
    """
    # pylint: disable=unspecified-encoding
    with open(version_file, 'r') as fp:
        for line in fp:
            m = re.search(r'__version__ += +"(.*)";', line)
            if m:
                return m.group(1)
        raise ValueError(
            "Could not find version in {}".format(version_file))


def get_requirements(requirements_file):
    """
    Parse the specified requirements file and return a list of its non-empty,
    non-comment lines. The returned lines are without any trailing newline
    characters.
    """
    # pylint: disable=unspecified-encoding
    with open(requirements_file, 'r') as fp:
        lines = fp.readlines()
    reqs = []
    for line in lines:
        line = line.strip('\n')
        if not line.startswith('#') and line != '':
            reqs.append(line)
    return reqs


def read_file(a_file):
    """
    Read the specified file and return its content as one string.
    """
    # pylint: disable=unspecified-encoding
    with open(a_file, 'r') as fp:
        content = fp.read()
    return content


class PytestCommand(setuptools.Command):
    """
    Base class for setup.py commands for executing tests for this package
    using pytest.

    Note on the class name: Because distutils.dist._show_help() shows the class
    name for the setup.py command name instead of invoking get_command_name(),
    the classes that get registered as commands must have the command name.
    """

    description = None  # Set by subclass
    my_test_dirs = None  # Set by subclass

    user_options = [
        (
            'pytest-options=',  # '=' indicates it requires an argument
            None,  # no short option
            "additional options for pytest, as one argument"
        ),
    ]

    def initialize_options(self):
        """
        Standard method called by setup to initialize options for the command.
        """
        # pylint: disable=attribute-defined-outside-init
        self.test_opts = None
        self.test_dirs = None
        self.pytest_options = None
        # pylint: enable=attribute-defined-outside-init

    def finalize_options(self):
        """
        Standard method called by setup to finalize options for the command.
        """
        # pylint: disable=attribute-defined-outside-init
        self.test_opts = [
            '--color=yes',
            '-s',
            '-W', 'default',
            '-W', 'ignore::PendingDeprecationWarning',
        ]
        if sys.version_info[0] == 3:
            self.test_opts.extend([
                '-W', 'ignore::ResourceWarning',
            ])
        self.test_dirs = self.my_test_dirs
        # pylint: enable=attribute-defined-outside-init

    def run(self):
        """
        Standard method called by setup to execute the command.
        """

        # deferred import so install does not depend on it
        import pytest  # pylint: disable=import-outside-toplevel

        args = self.test_opts
        if self.pytest_options:
            args.extend(self.pytest_options.split(' '))
        args.extend(self.test_dirs)

        if self.dry_run:
            self.announce("Dry-run: pytest {}".format(' '.join(args)),
                          level=log.INFO)
            return 0

        self.announce("pytest {}".format(' '.join(args)),
                      level=log.INFO)
        rc = pytest.main(args)
        return rc


class test(PytestCommand):
    # pylint: disable=invalid-name
    """
    Setup.py command for executing unit and function tests.
    """
    description = "macos-oslog: Run unit tests using pytest"
    my_test_dirs = ['tests/unittest']


# pylint: disable=invalid-name
requirements = get_requirements('requirements.txt')
install_requires = [req for req in requirements
                    if req and not re.match(r'[^:]+://', req)]
dependency_links = [req for req in requirements
                    if req and re.match(r'[^:]+://', req)]
test_requirements = get_requirements('test-requirements.txt')

package_version = get_version(os.path.join('src', 'macos_oslog.c'))

# Docs on setup():
# * https://docs.python.org/2.7/distutils/apiref.html?
#   highlight=setup#distutils.core.setup
# * https://setuptools.readthedocs.io/en/latest/setuptools.html#
#   new-and-changed-setup-keywords
setuptools.setup(
    name='macos-oslog',
    version=package_version,
    packages=[
    ],
    ext_modules=[
        Extension("macos_oslog", ["src/macos_oslog.c"])
    ],
    include_package_data=True,  # Includes MANIFEST.in files into sdist (only)
    scripts=[
        # add any scripts
    ],
    install_requires=install_requires,
    dependency_links=dependency_links,
    extras_require={
        "test": test_requirements,
    },
    cmdclass={
        'test': test,
    },
    description=("Python bindings for the unified logging and tracing "
                 "system of macOS"),
    long_description=read_file('README.rst'),
    long_description_content_type='text/x-rst',
    license="Apache Software License 2.0",
    author="Andreas Maier",
    author_email='andreas.r.maier@gmx.de',
    maintainer="Andreas Maier",
    maintainer_email='andreas.r.maier@gmx.de',
    url='https://github.com/andy-maier/macos-oslog',
    project_urls={
        'Bug Tracker': 'https://github.com/andy-maier/macos-oslog/issues',
        'Documentation': 'https://macos_oslog.readthedocs.io/en/latest/',
        'Source Code': 'https://github.com/andy-maier/macos-oslog',
    },

    options={'bdist_wheel': {'universal': True}},
    zip_safe=True,  # This package can safely be installed from a zip file
    platforms='Darwin',

    python_requires='>=2.7, !=3.0.*, !=3.1.*, !=3.2.*, !=3.3.*, !=3.4.*',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: Apache Software License',
        'Operating System :: MacOS',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ]
)
