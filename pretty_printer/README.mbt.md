# `dii_user/moonbit_debugged/pretty_printer`

This package provides small, line-based pretty-printing primitives. It keeps
layout (lines + size) separate from parenthesis metadata so callers can decide
when to wrap sub-expressions.

## Core types

- `ContentParens`: layout-only content (`lines` + `size`). Use it with
  `verbatim`, `surround`, `indent`, `comma_seq`, and `+` to build blocks.
- `Content`: layout plus a `needs_parens` hint for embedding. The library never
  adds parentheses automatically; treat this flag as metadata.

Convert between them with `parens`/`no_parens` (set the hint) and `no_wrap`
(drop the hint). `print_content` only accepts `ContentParens`.

`size` is a heuristic used by `with_resizing` and `compact` to choose between
single-line and multi-line output.

## Example

```mbt check
///|
test {
  let seq = comma_seq("[ ", " ]", [verbatim("a"), verbatim("b")])
  inspect(print_content(seq.compact().no_wrap()), content="[ a, b ]")
}
```

## Using the paren hint

```mbt check
///|
test {
  let expr = parens(verbatim("x + y"))
  let rendered = if expr.needs_parens {
    print_content(surround("(", ")", expr.no_wrap()))
  } else {
    print_content(expr.no_wrap())
  }
  inspect(rendered, content="(x + y)")
}
```
