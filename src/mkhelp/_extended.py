#!/usr/bin/env python3
from __future__ import annotations

import logging
import pathlib
from importlib import resources
from typing import Iterable, Iterator, Union

from mkhelp import _base

logger = logging.getLogger(__name__)


class RestructuredTextFormatter(_base.Formatter):
    @classmethod
    def lines(cls, docstrings: Iterable[_base.Docstring]) -> Iterator[str]:
        # TODO: Add anchor to enable references
        yield "********"
        yield "Makefile"
        yield "********"
        yield ""
        yield "This document describes a selection of helpful make targets."
        yield ""
        for docstring in docstrings:
            ref = docstring.ref
            if isinstance(ref, _base.Section):
                yield from docstring.lines
            elif isinstance(ref, _base.Subsection):
                yield from docstring.lines
            elif isinstance(ref, _base.Target):
                yield ref
                for line in docstring.lines:
                    yield "  " + line
            else:
                assert False
            yield ""


class MarkdownFormatter(_base.Formatter):
    @classmethod
    def lines(cls, docstrings: Iterable[_base.Docstring]) -> Iterator[str]:
        for docstring in docstrings:
            ref = docstring.ref
            if isinstance(ref, _base.Section):
                yield f"# {docstring.lines[0]}"
                for line in docstring.lines[2:]:
                    yield line
            elif isinstance(ref, _base.Subsection):
                yield f"## {docstring.lines[0]}"
                for line in docstring.lines[2:]:
                    yield line
            elif isinstance(ref, _base.Target):
                yield ref
                yield f": {docstring.lines[0]}"
            else:
                assert False
            yield ""


class RustdocFormatter(_base.Formatter):
    @classmethod
    def lines(cls, docstrings: Iterable[_base.Docstring]) -> Iterator[str]:
        for line in MarkdownFormatter.lines(docstrings):
            yield "//! " + line


FORMATTERS = {
    "help": _base.HelpFormatter,
    "md": MarkdownFormatter,
    "rs": RustdocFormatter,
    "rst": RestructuredTextFormatter,
}


def docs(src: Union[pathlib.Path, str], dst_fmt: str) -> str:
    """Return the rendered documentation

    :param src: Location of makefile
    :param dst_fmt: Documentation format (one of help, md, rs or rst)
    """
    src = pathlib.Path(src)
    formatter = FORMATTERS[dst_fmt]
    with src.open(encoding="utf8") as f:
        docstrings = _base.Docstring.take_all(_base.Stream(f.readlines()))
    return "\n".join(formatter.lines(docstrings)) + "\n"


def script() -> str:
    """Return a script to be used by makefile to render help message"""
    return resources.read_text("mkhelp", "_base.py")
