"""
Test import and versioning of the package.
"""


def test_import():
    """
    Test import of the package.
    """
    import macos_oslog  # noqa: F401 pylint: disable=import-outside-toplevel
    assert macos_oslog


def test_versioning():
    """
    Test import of the package.
    """
    import macos_oslog  # noqa: F401 pylint: disable=import-outside-toplevel
    # pylint: disable=c-extension-no-member
    assert macos_oslog.__version__
    # pylint: disable=c-extension-no-member
    assert isinstance(macos_oslog.__version__, str)
