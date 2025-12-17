# `dii_user/moonbit_debugged/repr`

This package defines `Repr`: a small, structural, tree-shaped representation
used by `dii_user/moonbit_debugged` for:

- pretty-printing (`dii_user/moonbit_debugged/pretty_print`)
- diffing (`dii_user/moonbit_debugged/diff`)
- the `Debug` trait (`dii_user/moonbit_debugged`)

`Repr` is exported as a readonly enum (`pub enum Repr`), so it can be
pattern-matched outside the package but not directly constructed. Use the smart
constructors (`Repr::...`) or the convenience functions (`int`, `record`, ...).

## Records

A record node is represented structurally as:

- `Record([Prop(name, value), ...])`

So for a value conceptually shaped like:

```text
record { x : Int; y : String }
```

the corresponding `Repr` is:

```text
Record([
  Prop("x", IntLit(...)),
  Prop("y", StringLit(...)),
])
```

### Example (runnable)

```mbt test
let r : Repr = record([("x", int(1)), ("y", string("hi"))])
match r {
  Repr::Record(
    [
      Repr::Prop("x", Repr::IntLit(1)),
      Repr::Prop("y", Repr::StringLit("hi")),
    ],
  ) => ()
  _ => fail("unexpected Repr shape for record {x:Int; y:String}")
}
```

