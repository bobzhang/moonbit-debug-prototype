///|
/// Rendered content with line layout and a paren hint for embedding.
/// `needs_parens` is metadata only; callers decide whether to wrap.
pub struct Content {
  size : Int
  lines : Array[String]
  needs_parens : Bool
} derive(Show, Eq)

///|

///|
/// Layout-only content without paren metadata.
/// Use this for line transforms/concatenation, then choose `parens` or
/// `no_parens` when embedding into a parent node.
pub struct ContentParens {
  size : Int
  lines : Array[String]
} derive(Show, Eq)

///|
/// Concatenate two layout blocks and add their sizes.
pub impl Add for ContentParens with add(self, other) {
  { size: self.size + other.size, lines: self.lines + other.lines }
}

///|
/// Empty content value (size 0, no paren hint).
pub fn empty_content() -> Content {
  { size: 0, lines: [], needs_parens: false }
}

///|
/// Single literal token as a `ContentParens` (size 1).
pub fn verbatim(x : String) -> ContentParens {
  { size: 1, lines: [x] }
}

///|
/// Build a `ContentParens` from explicit size and lines.
/// `size` is a heuristic used for compact-vs-multiline decisions.
pub fn content_parens(size : Int, lines : Array[String]) -> ContentParens {
  { size, lines }
}

///|
/// Render any `Show` value as a leaf content node.
/// `needs_parens` is a hint for callers, not an automatic wrapper.
pub fn[T : Show] leaf(x : T, needs_parens? : Bool = false) -> Content {
  { size: 1, lines: [repr(x)], needs_parens }
}

///|
/// Render any `Show` value as a leaf with a type suffix.
/// `needs_parens` is a hint for callers, not an automatic wrapper.
pub fn[T : Show] leaf_with_suffix(
  x : T,
  suffix : String,
  needs_parens? : Bool = false,
) -> Content {
  { size: 1, lines: [repr(x) + suffix], needs_parens }
}

///|
/// Map a transformation over the lines of `ContentParens`.
/// The size is preserved.
fn with_lines(
  r : ContentParens,
  f : (Array[String]) -> Array[String],
) -> ContentParens {
  { size: r.size, lines: f(r.lines) }
}

///|
/// Map a transformation over the lines of `Content`.
/// The size and paren hint are preserved.
fn Content::with_lines_content(
  r : Content,
  f : (Array[String]) -> Array[String],
) -> Content {
  { size: r.size, lines: f(r.lines), needs_parens: r.needs_parens }
}

///|
/// Surround multi-line content with a prefix/suffix, preserving layout.
fn surround_lines(
  start : String,
  finish : String,
  lines : Array[String],
) -> Array[String] {
  match lines {
    [] => [start + finish]
    [item] => [start + item + finish]
    [first, ..] => {
      let n = lines.length()
      let middle = if n <= 2 { [] } else { lines[1:n - 1].to_array() }
      let last = lines[n - 1]
      [start + first] + middle + [last + finish]
    }
  }
}

///|
/// Surround content with a prefix/suffix, preserving layout.
pub fn surround(
  start : String,
  finish : String,
  r : ContentParens,
) -> ContentParens {
  with_lines(r, fn(lines) { surround_lines(start, finish, lines) })
}

///|
/// Convert `Content` to `ContentParens` and drop the paren hint.
pub fn Content::no_wrap(c : Content) -> ContentParens {
  { size: c.size, lines: c.lines }
}

///|
/// Mark a content chunk as needing parentheses when embedded.
/// This sets metadata only; it does not change the lines.
pub fn parens(r : ContentParens) -> Content {
  { size: r.size, lines: r.lines, needs_parens: true }
}

///|
/// Mark a content chunk as not needing parentheses when embedded.
/// This sets metadata only; it does not change the lines.
pub fn no_parens(r : ContentParens) -> Content {
  { size: r.size, lines: r.lines, needs_parens: false }
}

///|
/// Compact multi-line output into a single line when possible.
#warnings("-deprecated")
fn compact_lines(lines : Array[String]) -> Array[String] {
  match lines {
    [] => []
    [x] => [x]
    [first, ..] => {
      let n = lines.length()
      let middle : ArrayView[String] = if n <= 2 { [] } else { lines[1:n - 1] }
      let last = lines[n - 1]
      let parts : Array[StringView] = [first]
      for m in middle {
        parts.push(m.trim_space())
      }
      parts.push(last.trim_space())
      [parts.join(" "[:])]
    }
  }
}

///|
/// Compact a `Content` value (paren hint preserved).
pub fn Content::compact(r : Content) -> Content {
  r.with_lines_content(compact_lines)
}

///|
/// Indent every line by a fixed prefix.
pub fn indent(prefix : String, r : ContentParens) -> ContentParens {
  with_lines(r, fn(lines) { lines.map(fn(line) { prefix + line }) })
}

///|
/// Join content chunks with commas and consistent indentation.
fn comma_seq_lines(
  begin : String,
  end : String,
  contents : Array[Array[String]],
) -> Array[String] {
  fn spacer(begin : String) -> String {
    " ".repeat(begin.length())
  }

  let lines = match contents {
    [] => [begin + end]
    [item] => surround_lines(begin, end, item)
    [first, ..] => {
      let n = contents.length()
      let middle = if n <= 2 { [] } else { contents[1:n - 1].to_array() }
      let last = contents[n - 1]
      let space = spacer(begin)
      let middle_lines = middle.fold(init=[], fn(acc, item) {
        acc + surround_lines(space, ",", item)
      })
      surround_lines(begin, ",", first) +
      middle_lines +
      surround_lines(space, end, last)
    }
  }
  lines.filter(fn(line) { line != "" })
}

///|
/// Build a comma-separated sequence as `Content`.
/// The result has `needs_parens = false`; wrap explicitly if needed.
pub fn comma_seq(
  begin : String,
  end : String,
  contents : Array[ContentParens],
) -> Content {
  let mut size = 0
  for c in contents {
    size += c.size
  }
  {
    size,
    lines: comma_seq_lines(begin, end, contents.map(fn(c) { c.lines })),
    needs_parens: false,
  }
}

///|
/// Convert content into a final `String` with newline separators.
/// Resolve paren hints before calling this (often via `no_wrap`).
pub fn print_content(r : ContentParens) -> String {
  r.lines.join("\n"[:])
}

///|
/// Total size of a node (root + children), used for compact decisions.
pub fn measure(root_size : Int, children : Array[Content]) -> Int {
  let mut total = root_size
  for c in children {
    total += c.size
  }
  total
}

///|
/// Render compactly when the measured size stays under `threshold`.
pub fn with_resizing(
  root_size : Int,
  threshold : Int,
  f : (Array[Content]) -> Content,
  children : Array[Content],
) -> Content {
  if measure(root_size, children) <= threshold {
    f(children).compact()
  } else {
    f(children)
  }
}
