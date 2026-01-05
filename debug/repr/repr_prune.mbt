///|
/// Whether visiting this node should consume (decrement) the remaining depth budget.
///
/// This is used by depth-limited pruning: structural edge nodes like
/// `RecordField` / `EnumLabeledArg` / `MapEntry` do not count as a depth level,
/// so field names / labels can still be preserved when pruning.
pub fn Repr::info_adds_depth(info : Repr) -> Bool {
  match info {
    RecordField(_, _) | EnumLabeledArg(_, _) | MapEntry(_, _) => false
    _ => true
  }
}

///|
/// Prune a `Repr` tree to a given depth (replacing pruned subtrees).
///
/// Parameters:
/// - `depth~`: maximum depth. Values `<= 0` are treated as `1`.
/// - `replacement?`: the node used to replace pruned subtrees.
///   Defaults to `Repr::omitted()`.
///
/// Semantics:
/// - Leaf nodes are never replaced.
/// - When the depth budget is exhausted and the node has children:
///   - if `info_adds_depth() == false`, pruning continues into its children;
///   - otherwise the whole subtree is replaced by `replacement`.
pub fn Repr::prune_info(
  info : Repr,
  replacement? : Repr = Repr::omitted(),
  depth~ : Int,
) -> Repr {
  fn go(d : Int, node : Repr) -> Repr {
    let children = node.children()
    if d <= 0 {
      if children.is_empty() {
        node
      } else if !node.info_adds_depth() {
        node.with_children(children.map(fn(child) { go(d, child) }))
      } else {
        replacement
      }
    } else if children.is_empty() {
      node
    } else {
      let next_depth = if node.info_adds_depth() { d - 1 } else { d }
      node.with_children(children.map(fn(child) { go(next_depth, child) }))
    }
  }

  go(Int::max(1, depth), info)
}
