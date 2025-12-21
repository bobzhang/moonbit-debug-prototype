///|
fn print_opts() -> PrettyPrintOptions {
  { max_depth: None, compact_threshold: 100, use_ansi: false }
}

///|
test "docs: building Repr manually" {
  let r = @repr.Repr::record({
    "answer": @repr.Repr::int(42),
    "xs": @repr.Repr::array([
      @repr.Repr::int(1),
      @repr.Repr::int(2),
      @repr.Repr::int(3),
    ]),
    "tag": @repr.Repr::ctor("Ok", [(None, @repr.Repr::string("done"))]),
  })
  inspect(
    pretty_print_repr_with(print_opts(), r),
    content="{ answer: 42, xs: [ 1, 2, 3 ], tag: Ok(\"done\") }",
  )
}

///|
test "docs: record keys are quoted when needed" {
  let r = @repr.Repr::record({
    "snake_case_ok": @repr.Repr::int(1),
    "with space": @repr.Repr::int(2),
    "k-v": @repr.Repr::int(3),
    "CamelCase": @repr.Repr::int(4),
  })
  inspect(
    pretty_print_repr_with(print_opts(), r),
    content="{ snake_case_ok: 1, \"with space\": 2, \"k-v\": 3, \"CamelCase\": 4 }",
  )
}

///|
test "docs: compact_threshold controls single-line vs multi-line" {
  let xs = @repr.Repr::array([
    @repr.Repr::int(1),
    @repr.Repr::int(2),
    @repr.Repr::int(3),
  ])
  let compact = pretty_print_repr(xs)
  let expanded = pretty_print_repr_with(
    { max_depth: None, compact_threshold: 0, use_ansi: false },
    xs,
  )
  inspect(compact, content="[ 1, 2, 3 ]")
  inspect(
    expanded,
    content=(
      #|[ 1,
      #|  2,
      #|  3 ]
    ),
  )
}

///|
test "docs: diff_repr_with can ignore tiny float changes" {
  let strict : @diff.DiffOptions = { max_relative_error: 0.0 }
  let tolerant : @diff.DiffOptions = { max_relative_error: 1.0e-12 }
  let print_opts = print_opts()
  let x = @repr.Repr::double(1.0)
  let y = @repr.Repr::double(1.0 + 1.0e-13)
  inspect(
    (
      pretty_print_delta_with(print_opts, @diff.diff_repr_with(strict, x, y)),
      pretty_print_delta_with(print_opts, @diff.diff_repr_with(tolerant, x, y)),
    ),
    content="(\"-1 +1.0000000000001\", \"1\")",
  )
}
