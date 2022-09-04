#!/usr/bin/env python
"""
Python setup script for the macos-oslog project.
"""

import os
import re
# setuptools needs to be imported before distutils in order to work.
import setuptools

# pylint: disable=wrong-import-order,deprecated-module
from distutils.core import Extension


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


# pylint: disable=invalid-name
requirements = get_requirements('requirements.txt')
install_requires = [req for req in requirements
                    if req and not re.match(r'[^:]+://', req)]
dependency_links = [req for req in requirements
                    if req and re.match(r'[^:]+://', req)]

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
    extras_require={},
    cmdclass={},
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
        'Documentation': 'https://andy-maier.github.io/macos-oslog/html/docs/',
        'Source Code': 'https://github.com/andy-maier/macos-oslog',
    },

    options={'bdist_wheel': {'universal': True}},
    zip_safe=True,  # This package can safely be installed from a zip file
    platforms='Darwin',

    python_requires='>=3.5',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: Apache Software License',
        'Operating System :: MacOS',
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
