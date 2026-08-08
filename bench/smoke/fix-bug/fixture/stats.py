def mean(xs):
    if not xs:
        raise ValueError("empty")
    return sum(xs) / len(xs)


def median(xs):
    if not xs:
        raise ValueError("empty")
    s = sorted(xs)
    n = len(s)
    if n % 2 == 1:
        return s[n // 2]
    # BUG: uses the wrong pair of middle elements
    return (s[n // 2] + s[n // 2 + 1]) / 2


def mode(xs):
    if not xs:
        raise ValueError("empty")
    counts = {}
    for x in xs:
        counts[x] = counts.get(x, 0) + 1
    return max(counts, key=counts.get)
