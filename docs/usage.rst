
.. _`Usage`:

Usage
-----

.. _`Overview`:

Overview
^^^^^^^^

.. automodule:: macos_oslog

.. _`Log class`:

Log class
^^^^^^^^^

.. autoclass:: macos_oslog.Log
   :members:
   :autosummary:
   :autosummary-inherited-members:

.. _`Log related functions`:

Log related functions
^^^^^^^^^^^^^^^^^^^^^

.. autofunction:: macos_oslog.os_log_create

.. autofunction:: macos_oslog.os_log_release

.. autofunction:: macos_oslog.os_log_enabled

.. autofunction:: macos_oslog.os_log

Log levels
^^^^^^^^^^

.. py:data:: OS_LOG_TYPE_DEBUG
   :type: int
   :value: 2

   Debug-level messages.

   Use this level to capture information that may be useful during development
   or while troubleshooting a specific problem.

   Debug-level messages are only captured in memory when debug logging is
   enabled through a configuration change. They are purged in accordance with
   the configuration's persistence setting.

.. py:data:: OS_LOG_TYPE_INFO
   :type: int
   :value: 1

   Info-level messages.

   Use this level to capture information that may be helpful, but isn't
   essential, for troubleshooting errors.

   Info-level messages are initially stored in memory buffers. Without a
   configuration change, they are not moved to the data store and are purged as
   memory buffers fill. They are, however, captured in the data store when
   faults and, optionally, errors occur. When info-level messages are added to
   the data store, they remain there until a storage quota is exceeded, at
   which point, the oldest messages are purged.

.. py:data:: OS_LOG_TYPE_DEFAULT
   :type: int
   :value: 0

   Default (=warning) level messages.

   Use this level to capture information about things that might result in a
   failure. This makes them equivalent to warning-level messages.

   Default-level messages are
   initially stored in memory buffers. Without a configuration change,
   they are compressed and moved to the data store as memory buffers fill.
   They remain there until a storage quota is exceeded, at which point,
   the oldest messages are purged.

.. py:data:: OS_LOG_TYPE_ERROR
   :type: int
   :value: 16

   Error-level messages.

   Use this log level to report process-level errors.

   Error-level messages are always
   saved in the data store. They remain there until a storage quota is
   exceeded, at which point, the oldest messages are purged. If an activity
   object exists, logging at this level captures information for the entire
   process chain.

.. py:data:: OS_LOG_TYPE_FAULT
   :type: int
   :value: 17

   Fault-level messages.

   Use this level only to capture system-level or multi-process information
   when reporting system errors.

   Fault-level messages are always
   saved in the data store. They remain there until a storage quota is
   exceeded, at which point, the oldest messages are purged. If an activity
   object exists, logging at this level captures information for the entire
   process chain.

Standard log objects
^^^^^^^^^^^^^^^^^^^^

.. py:data:: OS_LOG_DEFAULT
   :type: macos_oslog.Log

   A standard log object that initially has all levels enabled.

.. py:data:: OS_LOG_DISABLED
   :type: macos_oslog.Log

   A standard log object that initially has all levels disabled.
