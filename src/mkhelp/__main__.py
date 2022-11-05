import logging

import fire

from mkhelp import _extended


def main() -> None:
    logging.basicConfig(level=logging.DEBUG)
    fire.Fire(
        {
            "print_docs": _extended.docs,
            "print_script": _extended.script,
        }
    )
