Implement `satisfies(version, range_spec)` in semver.py, returning True/False, implementing node-semver's range semantics (default mode, i.e. includePrerelease=False). Pure Python stdlib only; do not install or vendor any package.

Required behavior:
- Versions: `major.minor.patch` with optional `-prerelease` (dot-separated identifiers) and optional `+build` metadata. A leading `v` in versions or in range operands must be tolerated.
- Build metadata is ignored entirely for comparison and matching.
- Comparators: `=`, `<`, `<=`, `>`, `>=`, and bare versions (implicit `=`).
- Space-separated comparators are ANDed; `||` separates alternatives (OR).
- Hyphen ranges: `A - B` (inclusive; partial versions on either side follow node-semver rules, e.g. `1.2.3 - 2.3` means `>=1.2.3 <2.4.0-0`).
- X-ranges and partials: `*`, `1.x`, `1.2.x`, `1.2`, `1`, and empty string (matches everything).
- Tilde: `~1.2.3`, `~1.2`, `~1`, `~0.2`, and tilde with prerelease like `~1.0.0-alpha`.
- Caret: `^1.2.3`, `^0.2.3`, `^0.0.3`, and caret with prerelease like `^1.2.3-alpha`.
- Prerelease comparison per SemVer 2.0.0: numeric identifiers compare numerically, alphanumeric lexically, numeric < alphanumeric, fewer fields < more fields when equal prefix, and a version with prerelease < the same version without.
- Prerelease exclusion rule (the default node-semver behavior): a version with a prerelease tag can only satisfy a range if at least one comparator in the same AND-group has a prerelease tag AND the same major.minor.patch tuple. E.g. `1.2.3-alpha` does NOT satisfy `>=1.0.0`, but DOES satisfy `>=1.2.3-0`.

Write your own sanity tests and make sure they pass before finishing. Correctness on edge cases is what is being graded.
