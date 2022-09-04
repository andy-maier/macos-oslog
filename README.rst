macos-oslog - Python bindings for the unified logging and tracing system of macOS
=================================================================================

.. image:: https://badge.fury.io/py/macos-oslog.svg
    :target: https://pypi.python.org/pypi/macos-oslog/
    :alt: Version on Pypi

.. image:: https://github.com/andy-maier/macos-oslog/workflows/test/badge.svg?branch=master
    :target: https://github.com/andy-maier/macos-oslog/actions/
    :alt: Test status (master)

.. image:: https://github.com/andy-maier/macos-oslog/workflows/docs/badge.svg?branch=master
    :target: https://github.com/andy-maier/macos-oslog/actions?query=workflow%3Adocs
    :alt: Docs build status (master)

.. # .. image:: https://coveralls.io/repos/github/andy-maier/macos-oslog/badge.svg?branch=master
.. #     :target: https://coveralls.io/github/andy-maier/macos-oslog?branch=master
.. #     :alt: Test coverage (master)


Overview
--------

This package is only for macOS and requires macOS 10.12 or higher.

Its purpose is to insert log messages into the unified logging and tracing system
of macOS. It does not support reading the unified log.


Installation
------------

To install the latest released version of the macos_oslog
package into your active Python environment:

.. code-block:: bash

    $ pip install macos-oslog

This will also install any prerequisite Python packages.

For more details and alternative ways to install, see
`Installation`_.

.. _Installation: https://andy-maier.github.io/macos-oslog/html/docs/install.html#installation

Documentation
-------------

* `Documentation for latest released version <https://andy-maier.github.io/macos-oslog/html/docs/>`_

Change History
--------------

* `Change history for latest released version <https://andy-maier.github.io/macos-oslog/html/docs/changes.html>`_

Quick Start
-----------

Example Python code:

.. code-block:: python

    #!/usr/bin/env python
    import macos_oslog

    log = macos_oslog.os_log_create(subsystem="com.acme.myapp", category="all")
    macos_oslog.os_log(log, macos_oslog.OS_LOG_TYPE_ERROR, "Some error happened")
    macos_oslog.os_log_release(log)

Example Python code using the predefined standard log provided by macOS:

.. code-block:: python

    #!/usr/bin/env python
    import macos_oslog

    macos_oslog.os_log(macos_oslog.OS_LOG_DEFAULT, macos_oslog.OS_LOG_TYPE_ERROR, "Some error happened")


Contributing
------------

For information on how to contribute to the
macos-oslog project, see
`Contributing <https://andy-maier.github.io/macos-oslog/html/docs/development.html#contributing>`_.


License
-------

The macos-oslog project is provided under the
`Apache Software License 2.0 <https://raw.githubusercontent.com/andy-maier/macos-oslog/master/LICENSE>`_.
