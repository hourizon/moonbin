///|
/// Minimal byte writer used by future encoders.
///
/// The first version stores byte values as `Int` entries in the range
/// `0..=255`. A later implementation can expose real `Bytes` output once the
/// encoder surface is ready.
pub struct ByteWriter {
  data : Array[Int]
}

///|
/// Creates an empty byte writer.
pub fn ByteWriter::new() -> ByteWriter {
  ByteWriter::{ data: [] }
}

///|
/// Returns the number of byte values written so far.
pub fn ByteWriter::len(self : ByteWriter) -> Int {
  self.data.length()
}

///|
/// Returns whether no byte values have been written.
pub fn ByteWriter::is_empty(self : ByteWriter) -> Bool {
  self.len() == 0
}

///|
/// Writes one unsigned byte value.
///
/// Returns `false` when `value` is outside the valid byte range.
pub fn ByteWriter::write_u8(self : ByteWriter, value : Int) -> Bool {
  if value < 0 || value > 255 {
    false
  } else {
    self.data.push(value)
    true
  }
}
