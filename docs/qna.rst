Questions and Answers
*********************

Why use rst in the documentation of this project (as opposed to e.g. md)?
    To evaluate if cross references and more advanced rst features can be used to help keep the docs consistent.
    Fo instance, if a make target is renamed then no docs should still reference the old name.

Why use rst in the docstrings?
    Since it is also the primary output format it makes the implementation easier.

Why use links instead of directives, like autodoc, to reference make targets?
    Want to test out the concept of linking docs and makefile before I invest the time it would take to implement custom directives.
