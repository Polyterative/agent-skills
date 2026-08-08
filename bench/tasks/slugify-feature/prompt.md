Add a `slugify(text)` function to util.py that:
- lowercases the input
- replaces any run of non-alphanumeric characters with a single hyphen
- strips leading/trailing hyphens
- collapses accented latin characters to their ascii base (e.g. "é" -> "e") using only the standard library

Also write unit tests for it in test_util.py using unittest, covering at least: basic sentence, accents, multiple consecutive separators, and leading/trailing punctuation. Ensure `python3 -m unittest test_util -v` passes.
