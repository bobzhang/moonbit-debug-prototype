// generated file, do not edit
///|
impl @debug.Debug for Pos with debug(self) {
  let fields : Map[String, @repr.Repr] = {}
  fields["x"] = @debug.debug(self.x)
  fields["y"] = @debug.debug(self.y)
  @repr.Repr::record(fields)
}

