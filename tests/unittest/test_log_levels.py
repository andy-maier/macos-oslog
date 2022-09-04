"""
Test log levels.
"""

import pytest
import macos_oslog


@pytest.mark.parametrize(
    "name, exp_type, exp_value", [
        ("OS_LOG_TYPE_DEBUG", int, 0x02),
        ("OS_LOG_TYPE_INFO", int, 0x01),
        ("OS_LOG_TYPE_DEFAULT", int, 0x00),
        ("OS_LOG_TYPE_ERROR", int, 0x10),
        ("OS_LOG_TYPE_FAULT", int, 0x11),
    ]
)
def test_log_levels(name, exp_type, exp_value):
    """
    Test global variables for the log levels.
    """
    level = getattr(macos_oslog, name, None)
    assert level is not None
    assert type(level) == exp_type  # pylint: disable=unidiomatic-typecheck
    assert level == exp_value
