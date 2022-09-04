// Copyright 2022 Andreas Maier. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <Python.h>
#include <structmember.h>

#include <os/log.h>  // macOS-specific header file


// The full version of this package including any development levels, as a
// string.
//
// Possible formats for this version string are:
//
// * "M.N.P.dev1": Development level 1 of a not yet released version M.N.P
// * "M.N.P": A released version M.N.P
static const char *__version__ = "0.5.0";


static char macos_oslog_module_docstring[] =
"This module provides Python bindings for the unified logging and tracing\n"
"system of macOS.\n"
"\n"
"It requires macOS 10.12 or higher.\n"
"\n"
"Log objects on macOS are encapsulated in Python using class\n"
":class:`macos_oslog.Log`.\n"
"\n"
"The standard log objects of macOS are available in Python as follows:\n"
"\n"
"* :data:`~macos_oslog.OS_LOG_DEFAULT`: Log object that is enabled for all\n"
"  log levels.\n"
"* :data:`~macos_oslog.OS_LOG_DISABLED`: Log object that is disabled for\n"
"  all log levels.\n"
"\n"
"Additional user-specific log objects can be created with\n"
":func:`~macos_oslog.os_log_create`. They should be released with\n"
":func:`~macos_oslog.os_log_release`.\n"
"\n"
"Log objects can be tested for being enabled for a specific log level with\n"
":func:`~macos_oslog.os_log_enabled`.\n"
"\n"
"The log levels supported by macOS are represented in Python as follows:\n"
"\n"
"* :data:`~macos_oslog.OS_LOG_TYPE_DEBUG`: Debug-level messages.\n"
"* :data:`~macos_oslog.OS_LOG_TYPE_INFO`: Info-level messages.\n"
"* :data:`~macos_oslog.OS_LOG_TYPE_DEFAULT`: Default/warning-level messages.\n"
"* :data:`~macos_oslog.OS_LOG_TYPE_ERROR`: Error-level messages.\n"
"* :data:`~macos_oslog.OS_LOG_TYPE_FAULT`: Fault-level messages.\n"
"\n"
"The unified logging and tracing system of macOS provides a central place\n"
"that has all log messages in memory buffers and that propagates log messages\n"
"to a data store dependent on the persistence setting of the log object.\n"
"These log levels have different settings as to whether they are put into the\n"
"log and whether they are propagated to the data store.\n"
"The 'log' command on macOS can be used to change the persistence setting of\n"
"a macOS log object.\n"
;


static char macos_oslog_Log_docstring[] =
"A macOS log object.\n"
"\n"
"A :class:`macos_oslog.Log` object encapsulates a macOS log object.\n"
"\n"
"A macOS log object has subsystem and category identifiers. These identifiers\n"
"allow filtering and grouping of log messages when viewing the unified log in\n"
"the macOS 'Console' app or with the 'log' command on macOS, and can be used\n"
"for log related settings in the logging system.\n"
;

typedef struct {
    PyObject_HEAD
    PyObject *subsystem;
    PyObject *category;
    long log;
} macos_oslog_Log_object;

static PyObject *macos_oslog_Log_new(PyTypeObject *type, PyObject *args, PyObject *kwargs) {
    // Note: __new__ methods ignore their additional input parameters after 'cls'.

    macos_oslog_Log_object *self;

    // Create the object
    self = (macos_oslog_Log_object *)type->tp_alloc(type, 0);

    // Initialize the object to a clean state
    if (self != NULL) {
        self->subsystem = PyUnicode_FromString("");
        if (self->subsystem == NULL) {
            Py_DECREF(self);
            return NULL;
        }
        self->category = PyUnicode_FromString("");
        if (self->category == NULL) {
            Py_DECREF(self);
            return NULL;
        }
        self->log = 0;
    }

    return (PyObject *)self;
}

static int macos_oslog_Log_init(macos_oslog_Log_object *self, PyObject *args, PyObject *kwargs) {
    // Python parameters
    PyObject *py_subsystem = NULL;  // Unicode object
    PyObject *py_category = NULL;  // Unicode object
    long py_log = 0;
    static char *kwlist[] = {"subsystem", "category", "log", NULL};

    PyObject *tmp;

    if (!PyArg_ParseTupleAndKeywords(
            args, kwargs, "UUl:macos_oslog.Log.__init__", kwlist,
            &py_subsystem, &py_category, &py_log))
    {
        return -1;
    }

    tmp = self->subsystem;
    Py_INCREF(py_subsystem);
    self->subsystem = py_subsystem;
    Py_XDECREF(tmp);

    tmp = self->category;
    Py_INCREF(py_category);
    self->category = py_category;
    Py_XDECREF(tmp);

    self->log = py_log;

    return 0;
}

static void macos_oslog_Log_dealloc(macos_oslog_Log_object *self) {
    Py_XDECREF(self->subsystem);
    Py_XDECREF(self->category);
    Py_TYPE(self)->tp_free((PyObject *)self);
}

static PyObject *macos_oslog_Log_repr(macos_oslog_Log_object *self) {
    return PyUnicode_FromFormat(
        "<macos_oslog.Log(subsystem='%U', category='%U', log=%p) at %p>",
        self->subsystem, self->category, (void*)self->log, self);
}

static PyObject *macos_oslog_Log_get_subsystem(macos_oslog_Log_object *self, void *closure) {
    Py_INCREF(self->subsystem);
    return self->subsystem;
}

static PyObject *macos_oslog_Log_get_category(macos_oslog_Log_object *self, void *closure) {
    Py_INCREF(self->category);
    return self->category;
}

static PyObject *macos_oslog_Log_get_log(macos_oslog_Log_object *self, void *closure) {
    return PyLong_FromLong(self->log);
}

static PyGetSetDef macos_oslog_Log_getsetters[] = {
    {
        "subsystem",
        (getter)macos_oslog_Log_get_subsystem,
        NULL,  // no setter -> readonly property
        "subsystem identifier of the macOS log object",
        NULL
    },
    {
        "category",
        (getter)macos_oslog_Log_get_category,
        NULL,  // no setter -> readonly property
        "category identifier of the macOS log object",
        NULL
    },
    {
        "log",
        (getter)macos_oslog_Log_get_log,
        NULL,  // no setter -> readonly property
        "opaque handle to the macOS log object",
        NULL
    },
    {NULL}
};

static PyTypeObject macos_oslog_Log_type = {
    PyVarObject_HEAD_INIT(NULL, 0)
    .tp_name = "macos_oslog.Log",
    .tp_doc = PyDoc_STR(macos_oslog_Log_docstring),
    .tp_basicsize = sizeof(macos_oslog_Log_object),
    .tp_itemsize = 0,
    .tp_flags = Py_TPFLAGS_DEFAULT,
    .tp_init = (initproc)macos_oslog_Log_init,
    .tp_new = (newfunc)macos_oslog_Log_new,
    .tp_dealloc = (destructor)macos_oslog_Log_dealloc,
    .tp_getset = macos_oslog_Log_getsetters,
    .tp_repr = (reprfunc)macos_oslog_Log_repr,
};


static char macos_oslog_os_log_create_docstring[] =
"Creates a new log object.\n"
"\n"
"The log object should be released when no longer used via\n"
":func:`~macos_oslog.os_log_release`.\n"
"\n"
"Parameters:\n"
"  subsystem (str): A subsystem identifier chosen by the caller.\n"
"    This identifier has macOS system-wide scope, but there can be multiple\n"
"    log objects that use the same subsystem identifier.\n"
"    It is recommended to use reverse DNS format (i.e.\n"
"    'com.company.mysubsystem').\n"
"    The subsystem identifier is used by macOS for categorization and\n"
"    filtering of related log messages, as well as for grouping related\n"
"    logging settings.\n"
"\n"
"  category (str): A category identifier chosen by the caller.\n"
"    This identifier has a scope only within the subsystem of the log object.\n"
"    There can be multiple log objects that use the same category identifier\n"
"    within a particular subsystem.\n"
"    MacOS uses the category identifier to categorize and filter related log\n"
"    messages, as well as to group related logging settings within the\n"
"    subsystem's settings. A category's logging settings override those of\n"
"    the parent subsystem.\n"
"\n"
"Returns:\n"
"  macos_oslog.Log: The new log object.\n"
;

static PyObject *macos_oslog_os_log_create(PyObject *self, PyObject *args, PyObject *kwargs) {

    // Python parameters and return value
    PyObject *py_subsystem = NULL;  // Unicode object
    PyObject *py_category = NULL;  // Unicode object
    static char *kwlist[] = {"subsystem", "category", NULL};
    PyObject *py_log;

    // Parameters and return value for os_log_create()
    const char *subsystem;
    const char *category;
    void *log;

    PyObject *log_args;

    if (!PyArg_ParseTupleAndKeywords(
            args, kwargs, "UU:macos_oslog.os_log_create", kwlist,
            &py_subsystem, &py_category))
    {
        return NULL;
    }

    subsystem = PyUnicode_AsUTF8(py_subsystem);
    category = PyUnicode_AsUTF8(py_category);

    log = os_log_create(subsystem, category);

    // Create the Python Log object
    log_args = Py_BuildValue("OOl", py_subsystem, py_category, (long)log);
    py_log = PyObject_CallObject((PyObject *)&macos_oslog_Log_type, log_args);
    Py_DECREF(log_args);

    return py_log;
}


static char macos_oslog_os_log_release_docstring[] =
"Releases a log object.\n"
"\n"
"The log object must have been created with\n"
":func:`~macos_oslog.os_log_create`.\n"
"The standard log objects :data:`~macos_oslog.OS_LOG_DEFAULT` and\n"
":data:`~macos_oslog.OS_LOG_DISABLED` cannot be released.\n"
"\n"
"Parameters:\n"
"  log (macos_oslog.Log): The log object to be released.\n"
;

static PyObject *macos_oslog_os_log_release(PyObject *self, PyObject *args, PyObject *kwargs) {

    // Python parameters
    PyObject *py_log = NULL;
    static char *kwlist[] = {"log", NULL};

    // Parameters for os_release()
    void *log;

    char buf[200];

    if (!PyArg_ParseTupleAndKeywords(
            args, kwargs, "O:macos_oslog.os_log_release", kwlist,
            &py_log))
    {
        return NULL;
    }

    if (!PyObject_TypeCheck(py_log, &macos_oslog_Log_type)) {
        snprintf(buf, sizeof(buf),
                 "macos_oslog.os_log_release() argument 1 must be "
                 "macos_oslog.Log, not %s",
                 Py_TYPE(py_log)->tp_name);
        PyErr_SetString(PyExc_TypeError, buf);
        return NULL;
    }
    log = (void *)PyLong_AsLong(PyObject_GetAttrString(py_log, "log"));

    // Note: This is a memory release function, that is used on the log
    // objects. There is no specific log object release function in the macOS
    // logging API. We expose that at the Python level as a function only for
    // releasing log objects.
    os_release(log);

    Py_RETURN_NONE;
}


static char macos_oslog_os_log_enabled_docstring[] =
"Checks if a log object is enabled for a specific log level.\n"
"\n"
"The log object can have been created with :func:`~macos_oslog.os_log_create`\n"
"or can be one of the standard log objects :data:`~macos_oslog.OS_LOG_DEFAULT`\n"
"or :data:`~macos_oslog.OS_LOG_DISABLED`.\n"
"\n"
"Parameters:\n"
"  log (macos_oslog.Log): The log object to be checked.\n"
"\n"
"  level (int): Log level, using one of the following values:\n"
"    :data:`~macos_oslog.OS_LOG_TYPE_DEBUG`,\n"
"    :data:`~macos_oslog.OS_LOG_TYPE_INFO`,\n"
"    :data:`~macos_oslog.OS_LOG_TYPE_DEFAULT`,\n"
"    :data:`~macos_oslog.OS_LOG_TYPE_ERROR`,\n"
"    :data:`~macos_oslog.OS_LOG_TYPE_FAULT`.\n"
"\n"
"Returns:\n"
"  bool: Boolean indicating whether the log object is enabled for the\n"
"  specified log level.\n"
;

static PyObject *macos_oslog_os_log_enabled(PyObject *self, PyObject *args, PyObject *kwargs) {

    // Python parameters
    PyObject *py_log = NULL;
    int py_level = 0;
    static char *kwlist[] = {"log", "level", NULL};

    // Parameters for os_log_type_enabled()
    void *log;
    uint8_t level;

    char buf[200];

    if (!PyArg_ParseTupleAndKeywords(
            args, kwargs, "Oi:macos_oslog.os_log_enabled", kwlist,
            &py_log, &py_level))
    {
        return NULL;
    }

    if (!PyObject_TypeCheck(py_log, &macos_oslog_Log_type)) {
        snprintf(buf, sizeof(buf),
                 "macos_oslog.os_log_enabled() argument 1 must be "
                 "macos_oslog.Log, not %s",
                 Py_TYPE(py_log)->tp_name);
        PyErr_SetString(PyExc_TypeError, buf);
        return NULL;
    }
    log = (void *)PyLong_AsLong(PyObject_GetAttrString(py_log, "log"));
    level = (uint8_t)py_level;

    if (os_log_type_enabled(log, level)) {
        Py_RETURN_TRUE;
    } else {
        Py_RETURN_FALSE;
    }
}


static char macos_oslog_os_log_docstring[] =
"Inserts a log message into the unified logging and tracing system of macOS.\n"
"\n"
"The log message is inserted in accordance with the preferences specified by\n"
"the provided log object.\n"
"\n"
"For log messages that are configured to be written to the data store of the\n"
"logging system, the message is truncated to 1024 Bytes before being written.\n"
"This does not affect the corresponding log message in memory.\n"
"\n"
"The log object can have been created with :func:`~macos_oslog.os_log_create`\n"
"or can be one of the standard log objects :data:`~macos_oslog.OS_LOG_DEFAULT`\n"
"or :data:`~macos_oslog.OS_LOG_DISABLED`.\n"
"\n"
"The macOS logging system automatically creates a timestamp for the log\n"
"message and captures process name, process ID, thread ID and log level.\n"
"Therefore, these values do not need to be put into the message string.\n"
"\n"
"Parameters:\n"
"\n"
"  log (macos_oslog.Log): The log object to be used.\n"
"\n"
"  level (int): Log level, using one of the following values:\n"
"    :data:`~macos_oslog.OS_LOG_TYPE_DEBUG`,\n"
"    :data:`~macos_oslog.OS_LOG_TYPE_INFO`,\n"
"    :data:`~macos_oslog.OS_LOG_TYPE_DEFAULT`,\n"
"    :data:`~macos_oslog.OS_LOG_TYPE_ERROR`,\n"
"    :data:`~macos_oslog.OS_LOG_TYPE_FAULT`.\n"
"\n"
"  message (str): The message string. Formatting strings are not supported,\n"
"   so any formatting needs to be done by the caller.\n"
;

static PyObject *macos_oslog_os_log(PyObject *self, PyObject *args, PyObject *kwargs) {

    // Python parameters
    PyObject *py_log = NULL;
    int py_level = 0;
    PyObject *py_message = NULL;  // Unicode object

    static char *kwlist[] = {"log", "level", "message", NULL};

    // Parameters for os_log_with_type()
    void *log;
    uint8_t level;
    const char *message;

    char buf[200];

    if (!PyArg_ParseTupleAndKeywords(
            args, kwargs, "OiU:macos_oslog.os_log", kwlist,
            &py_log, &py_level, &py_message))
    {
        return NULL;
    }

    if (!PyObject_TypeCheck(py_log, &macos_oslog_Log_type)) {
        snprintf(buf, sizeof(buf),
                 "macos_oslog.os_log() argument 1 must be "
                 "macos_oslog.Log, not %s",
                 Py_TYPE(py_log)->tp_name);
        PyErr_SetString(PyExc_TypeError, buf);
        return NULL;
    }
    log = (void *)PyLong_AsLong(PyObject_GetAttrString(py_log, "log"));
    level = (uint8_t)py_level;
    message = PyUnicode_AsUTF8(py_message);

    os_log_with_type(log, level, "%{public}s", message);

    Py_RETURN_NONE;
}

static PyMethodDef macos_oslog_methods[] = {
    {
        "os_log_create",
        (PyCFunction)macos_oslog_os_log_create,
        METH_VARARGS | METH_KEYWORDS,
        macos_oslog_os_log_create_docstring
    },
    {
        "os_log_release",
        (PyCFunction)macos_oslog_os_log_release,
        METH_VARARGS | METH_KEYWORDS,
        macos_oslog_os_log_release_docstring
    },
    {
        "os_log_enabled",
        (PyCFunction)macos_oslog_os_log_enabled,
        METH_VARARGS | METH_KEYWORDS,
        macos_oslog_os_log_enabled_docstring
    },
    {
        "os_log",
        (PyCFunction)macos_oslog_os_log,
        METH_VARARGS | METH_KEYWORDS,
        macos_oslog_os_log_docstring
    },
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef macos_oslog_module = {
    PyModuleDef_HEAD_INIT,
    "macos_oslog",
    macos_oslog_module_docstring,
    -1,
    macos_oslog_methods
};

PyMODINIT_FUNC PyInit_macos_oslog(void) {

    PyObject *m = NULL;
    PyObject *log_args = NULL;
    PyObject *py_log_default = NULL;
    PyObject *py_log_disabled = NULL;

    if (PyType_Ready(&macos_oslog_Log_type)) {
        return NULL;
    }

    m = PyModule_Create(&macos_oslog_module);
    if (m == NULL)
        return NULL;

    if (PyModule_AddStringConstant(m, "__version__", __version__))
        goto errors1;

    if (PyModule_AddIntConstant(m, "OS_LOG_TYPE_DEFAULT", OS_LOG_TYPE_DEFAULT))
        goto errors1;
    if (PyModule_AddIntConstant(m, "OS_LOG_TYPE_INFO", OS_LOG_TYPE_INFO))
        goto errors1;
    if (PyModule_AddIntConstant(m, "OS_LOG_TYPE_DEBUG", OS_LOG_TYPE_DEBUG))
        goto errors1;
    if (PyModule_AddIntConstant(m, "OS_LOG_TYPE_ERROR", OS_LOG_TYPE_ERROR))
        goto errors1;
    if (PyModule_AddIntConstant(m, "OS_LOG_TYPE_FAULT", OS_LOG_TYPE_FAULT))
        goto errors1;

    // Create a type object for the Log type
    Py_INCREF(&macos_oslog_Log_type);
    if (PyModule_AddObject(m, "Log", (PyObject *)&macos_oslog_Log_type))
        goto errors2;

    // Create a Python Log object for the standard log OS_LOG_DEFAULT
    log_args = Py_BuildValue("OOl", PyUnicode_FromString(""), PyUnicode_FromString(""),
                             (long)&_os_log_default);
    py_log_default = PyObject_CallObject((PyObject *)&macos_oslog_Log_type, log_args);
    Py_XDECREF(log_args);
    if (PyModule_AddObject(m, "OS_LOG_DEFAULT", (PyObject *)py_log_default))
        goto errors2;

    // Create a Python Log object for the standard log OS_LOG_DISABLED
    log_args = Py_BuildValue("OOl", PyUnicode_FromString(""), PyUnicode_FromString(""),
                             (long)&_os_log_disabled);
    py_log_disabled = PyObject_CallObject((PyObject *)&macos_oslog_Log_type, log_args);
    Py_XDECREF(log_args);
    if (PyModule_AddObject(m, "OS_LOG_DISABLED", (PyObject *)py_log_disabled))
        goto errors2;

    return m;

errors2:
    Py_DECREF(&macos_oslog_Log_type);

errors1:
    Py_XDECREF(py_log_default);
    Py_XDECREF(py_log_disabled);
    Py_XDECREF(m);
    return NULL;
}
