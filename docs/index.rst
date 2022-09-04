
macos-oslog - Python bindings for the unified logging and tracing system of macOS
*********************************************************************************

This package is only for macOS and requires macOS 10.12 or higher.

Its purpose is to insert log messages into the unified logging and tracing system
of macOS. It does not support reading the unified log.

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

The project home page and repo is: https://github.com/andy-maier/macos-oslog

.. toctree::
   :maxdepth: 2
   :numbered:

   install.rst
   usage.rst
   development.rst
   appendix.rst
   changes.rst
