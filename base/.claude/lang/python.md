# Python

Write plain, direct Python. Functions over classes unless state is genuinely needed.

- **Standard library first**: Don't reach for a dependency when `os`, `pathlib`, `itertools`, or `collections` already suffices.
- **Type hints**: Annotate function signatures. Use built-in generics (`list[str]`, `dict[str, int]`) over `typing` imports.
- **No class ceremony**: A module with functions is fine. Use a class only for encapsulated mutable state or a protocol.
- **Comprehensions over map/filter**: Avoid `lambda` outside of trivial `key=` arguments.
- **Explicit errors**: No bare `except:`. Catch specific exceptions. Let unexpected errors propagate.
