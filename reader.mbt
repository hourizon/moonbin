///|
/// Byte reader used by moonbin decoders.
pub struct ByteReader {
  data : Bytes
  mut offset : Int
}

///|
/// Creates a byte reader from an array of byte values.
pub fn ByteReader::new(data : Bytes) -> ByteReader {
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
    let value = self.data[self.offset].to_int()
    self.offset = self.offset + 1
    Ok(value)
  }
}

///|
/// Reads an unsigned 32-bit integer in big-endian byte order.
pub fn ByteReader::read_u32(self : ByteReader) -> Result[UInt, DecodeError] {
  if self.remaining() < 4 {
    return Err(DecodeError::UnexpectedEOF)
  }
  let start = self.offset
  let value = (self.data[start].to_uint() << 24) |
    (self.data[start + 1].to_uint() << 16) |
    (self.data[start + 2].to_uint() << 8) |
    self.data[start + 3].to_uint()
  self.offset = start + 4
  Ok(value)
}

///|
/// Reads a signed 64-bit integer in big-endian byte order.
pub fn ByteReader::read_i64(self : ByteReader) -> Result[Int64, DecodeError] {
  if self.remaining() < 8 {
    return Err(DecodeError::UnexpectedEOF)
  }
  let start = self.offset
  let value = (self.data[start].to_uint().to_uint64() << 56) |
    (self.data[start + 1].to_uint().to_uint64() << 48) |
    (self.data[start + 2].to_uint().to_uint64() << 40) |
    (self.data[start + 3].to_uint().to_uint64() << 32) |
    (self.data[start + 4].to_uint().to_uint64() << 24) |
    (self.data[start + 5].to_uint().to_uint64() << 16) |
    (self.data[start + 6].to_uint().to_uint64() << 8) |
    self.data[start + 7].to_uint().to_uint64()
  self.offset = start + 8
  Ok(value.reinterpret_as_int64())
}

///|
/// Reads an IEEE 754 double in big-endian byte order.
pub fn ByteReader::read_f64(self : ByteReader) -> Result[Double, DecodeError] {
  match self.read_i64() {
    Ok(bits) => Ok(bits.reinterpret_as_double())
    Err(err) => Err(err)
  }
}

///|
/// Reads exactly `length` raw bytes.
pub fn ByteReader::read_bytes(
  self : ByteReader,
  length : Int,
) -> Result[Bytes, DecodeError] {
  if length < 0 {
    return Err(DecodeError::InvalidLength("negative byte length"))
  }
  if self.remaining() < length {
    return Err(DecodeError::UnexpectedEOF)
  }
  let start = self.offset
  let end = start + length
  let result = Bytes::from_array(self.data[start:end].to_array())
  self.offset = end
  Ok(result)
}
