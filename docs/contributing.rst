Contributing
************

This document describes how to contribute to this project


Prerequisites
=============
Some things that you may need to install manually

Pyenv
-----

While not necessary it makes it easier to handle multiple python versions and ensures that the intended python version is used.
Installing using the `Basic GitHub Checkout <https://github.com/pyenv/pyenv#basic-github-checkout>`_ method is convenient.


Environment
===========

Create and enter the development environment like

.. code-block:: bash

    . ./init_env.sh
    PIP_CONSTRAINT=constraints.txt pip install -r requirements.txt

Most important workflows have a make targets and can be listed with the :ref:`makefile.help` target.
Since it is the `.DEFAULT_GOAL` it can be omitted e.g. like

.. code-block:: bash

    make

The whole makefile is documented in :doc:`makefile`.