def process(lines):
    # parse, validate, aggregate and format sales records: "name,qty,price"
    records = []
    errors = []
    for i, line in enumerate(lines):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(",")
        if len(parts) != 3:
            errors.append(f"line {i + 1}: expected 3 fields")
            continue
        name = parts[0].strip()
        if not name:
            errors.append(f"line {i + 1}: empty name")
            continue
        try:
            qty = int(parts[1])
            price = float(parts[2])
        except ValueError:
            errors.append(f"line {i + 1}: bad number")
            continue
        if qty < 0 or price < 0:
            errors.append(f"line {i + 1}: negative value")
            continue
        records.append((name, qty, price))
    totals = {}
    for name, qty, price in records:
        totals[name] = totals.get(name, 0.0) + qty * price
    out = []
    for name in sorted(totals):
        out.append(f"{name}: {totals[name]:.2f}")
    if errors:
        out.append(f"errors: {len(errors)}")
    return "\n".join(out)
