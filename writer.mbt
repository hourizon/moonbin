///|
/// Byte writer used by moonbin encoders.
pub struct ByteWriter {
  buffer : @buffer.Buffer
}

///|
/// Creates an empty byte writer.
pub fn ByteWriter::new() -> ByteWriter {
  ByteWriter::{ buffer: @buffer.Buffer() }
}

///|
/// Returns the number of byte values written so far.
pub fn ByteWriter::len(self : ByteWriter) -> Int {
  self.buffer.length()
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
    self.buffer.write_byte(value.to_byte())
    true
  }
}

///|
/// Writes an unsigned 32-bit integer in big-endian byte order.
pub fn ByteWriter::write_u32(self : ByteWriter, value : UInt) -> Unit {
  self.buffer.write_uint_be(value)
}

///|
/// Writes a signed 64-bit integer in big-endian byte order.
pub fn ByteWriter::write_i64(self : ByteWriter, value : Int64) -> Unit {
  self.buffer.write_int64_be(value)
}

///|
/// Writes an IEEE 754 double in big-endian byte order.
pub fn ByteWriter::write_f64(self : ByteWriter, value : Double) -> Unit {
  self.buffer.write_double_be(value)
}

///|
/// Appends raw bytes.
pub fn ByteWriter::write_bytes(self : ByteWriter, value : Bytes) -> Unit {
  self.buffer.write_bytes(value[:])
}

///|
/// Returns a copy of all bytes written so far.
pub fn ByteWriter::to_bytes(self : ByteWriter) -> Bytes {
  self.buffer.to_bytes()
}
