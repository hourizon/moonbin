///|
/// Minimal byte reader used by future decoders.
///
/// The reader consumes the same temporary byte representation used by
/// `ByteWriter`: an `Array[Int]` where each item should be in the `0..=255`
/// range.
pub struct ByteReader {
  data : Array[Int]
  mut offset : Int
}

///|
/// Creates a byte reader from an array of byte values.
pub fn ByteReader::new(data : Array[Int]) -> ByteReader {
  ByteReader::{ data, offset: 0 }
}

///|
/// Returns the total number of byte values in this reader.
pub fn ByteReader::len(self : ByteReader) -> Int {
  self.data.length()
}

///|
/// Returns the current read position.
pub fn ByteReader::position(self : ByteReader) -> Int {
  self.offset
}

///|
/// Returns how many byte values are still unread.
pub fn ByteReader::remaining(self : ByteReader) -> Int {
  self.len() - self.offset
}

///|
/// Returns whether there are no unread byte values.
pub fn ByteReader::is_empty(self : ByteReader) -> Bool {
  self.remaining() == 0
}

///|
/// Reads one unsigned byte value and advances the read position.
pub fn ByteReader::read_u8(self : ByteReader) -> Result[Int, DecodeError] {
  if self.remaining() <= 0 {
    Err(DecodeError::UnexpectedEOF)
  } else {
    let value = self.data[self.offset]
    self.offset = self.offset + 1
    Ok(value)
  }
}
