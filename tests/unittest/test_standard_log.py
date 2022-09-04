"""
Test standard log objects.
"""

import pytest
import macos_oslog


# pylint: disable=c-extension-no-member
@pytest.mark.parametrize(
    "name, exp_type, exp_subsystem, exp_category", [
        ("OS_LOG_DEFAULT", macos_oslog.Log, "", ""),
        ("OS_LOG_DISABLED", macos_oslog.Log, "", ""),
    ]
)
def test_standard_log(name, exp_type, exp_subsystem, exp_category):
    """
    Test standard log objects.
    """
    log = getattr(macos_oslog, name, None)
    assert log is not None
    assert type(log) == exp_type  # pylint: disable=unidiomatic-typecheck

    log_subsystem = getattr(log, 'subsystem', None)
    assert log_subsystem is not None
    assert type(log_subsystem) == str  # pylint: disable=unidiomatic-typecheck
    assert log_subsystem == exp_subsystem

    log_category = getattr(log, 'category', None)
    assert log_category is not None
    assert type(log_category) == str  # pylint: disable=unidiomatic-typecheck
    assert log_category == exp_category

    log_log = getattr(log, 'log', None)
    assert log_log is not None
    assert type(log_log) == int  # pylint: disable=unidiomatic-typecheck
