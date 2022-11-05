import pathlib

import pytest

import mkhelp
from mkhelp import _extended

PROJECT_ROOT = pathlib.Path(__file__).parents[1]


def test_version_is_string() -> None:
    # The real reason for having this test is so that pytest will find something in an
    # otherwise empty project.

    # As opposed to some more structured type
    assert isinstance(mkhelp.__version__, str)


@pytest.mark.parametrize("dst_fmt", _extended.FORMATTERS.keys())
def test_rendering_docs_does_not_raise(dst_fmt: str) -> None:
    print(_extended.docs(PROJECT_ROOT / "Makefile", dst_fmt))


def test_script_is_ecactly_as_in_source() -> None:
    source_file = PROJECT_ROOT / "src/mkhelp/_base.py"
    assert _extended.script() == source_file.read_text()
