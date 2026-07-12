///|
const TAG_NULL : Int = 0x00

///|
const TAG_BOOL : Int = 0x01

///|
const TAG_INT : Int = 0x02

///|
const TAG_DOUBLE : Int = 0x03

///|
const TAG_STRING : Int = 0x04

///|
const TAG_BYTES : Int = 0x05

///|
const TAG_ARRAY : Int = 0x06

///|
const TAG_OBJECT : Int = 0x07

///|
/// Resource limits applied while decoding untrusted input.
pub(all) struct DecodeLimits {
  max_depth : Int
  max_collection_items : Int
  max_value_bytes : Int
} derive(Eq, Debug)

///|
/// Returns conservative default limits for one decoded value.
pub fn default_decode_limits() -> DecodeLimits {
  { max_depth: 64, max_collection_items: 1000000, max_value_bytes: 16777216 }
}

///|
fn write_tag(writer : ByteWriter, tag : Int) -> Unit {
  ignore(writer.write_u8(tag))
}

///|
fn write_length(writer : ByteWriter, length : Int) -> Unit {
  writer.write_u32(length.reinterpret_as_uint())
}

///|
fn encode_into(writer : ByteWriter, value : BinValue) -> Unit {
  match value {
    Null => write_tag(writer, TAG_NULL)
    Bool(value) => {
      write_tag(writer, TAG_BOOL)
      ignore(writer.write_u8(if value { 1 } else { 0 }))
    }
    Int(value) => {
      write_tag(writer, TAG_INT)
      writer.write_i64(value.to_int64())
    }
    Double(value) => {
      write_tag(writer, TAG_DOUBLE)
      writer.write_f64(value)
    }
    String(value) => {
      write_tag(writer, TAG_STRING)
      let bytes = @utf8.encode(value[:])
      write_length(writer, bytes.length())
      writer.write_bytes(bytes)
    }
    Bytes(value) => {
      write_tag(writer, TAG_BYTES)
      write_length(writer, value.length())
      writer.write_bytes(value)
    }
    Array(values) => {
      write_tag(writer, TAG_ARRAY)
      write_length(writer, values.length())
      for value in values {
        encode_into(writer, value)
      }
    }
    Object(entries) => {
      write_tag(writer, TAG_OBJECT)
      write_length(writer, entries.length())
      for entry in entries {
        let (key, value) = entry
        let key_bytes = @utf8.encode(key[:])
        write_length(writer, key_bytes.length())
        writer.write_bytes(key_bytes)
        encode_into(writer, value)
      }
    }
  }
}

///|
/// Encodes one `BinValue` into the moonbin v1 wire format.
pub fn encode(value : BinValue) -> Bytes {
  let writer = ByteWriter::new()
  encode_into(writer, value)
  writer.to_bytes()
}

///|
fn read_length(reader : ByteReader) -> Result[Int, DecodeError] {
  match reader.read_u32() {
    Err(err) => Err(err)
    Ok(value) =>
      if value > 0x7FFFFFFFU {
        Err(DecodeError::InvalidLength("length exceeds MoonBit Int range"))
      } else {
        Ok(value.reinterpret_as_int())
      }
  }
}

///|
fn decode_utf8(bytes : Bytes) -> Result[String, DecodeError] {
  Ok(@utf8.decode(bytes[:])) catch {
    _ => Err(DecodeError::InvalidType("valid UTF-8", "malformed bytes"))
  }
}

///|
fn decode_from(
  reader : ByteReader,
  limits : DecodeLimits,
  depth : Int,
) -> Result[BinValue, DecodeError] {
  if depth > limits.max_depth {
    return Err(DecodeError::LimitExceeded("maximum nesting depth"))
  }
  let tag = match reader.read_u8() {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  match tag {
    TAG_NULL => Ok(BinValue::Null)
    TAG_BOOL =>
      match reader.read_u8() {
        Ok(0) => Ok(BinValue::Bool(false))
        Ok(1) => Ok(BinValue::Bool(true))
        Ok(_) =>
          Err(DecodeError::InvalidType("bool payload 0 or 1", "invalid byte"))
        Err(err) => Err(err)
      }
    TAG_INT =>
      match reader.read_i64() {
        Err(err) => Err(err)
        Ok(raw) => {
          let value = raw.to_int()
          if value.to_int64() == raw {
            Ok(BinValue::Int(value))
          } else {
            Err(
              DecodeError::InvalidType("MoonBit Int range", "i64 value \{raw}"),
            )
          }
        }
      }
    TAG_DOUBLE =>
      match reader.read_f64() {
        Ok(value) => Ok(BinValue::Double(value))
        Err(err) => Err(err)
      }
    TAG_STRING => {
      let length = match read_length(reader) {
        Ok(value) => value
        Err(err) => return Err(err)
      }
      if length > limits.max_value_bytes {
        return Err(DecodeError::LimitExceeded("string byte length"))
      }
      let bytes = match reader.read_bytes(length) {
        Ok(value) => value
        Err(err) => return Err(err)
      }
      match decode_utf8(bytes) {
        Ok(value) => Ok(BinValue::String(value))
        Err(err) => Err(err)
      }
    }
    TAG_BYTES => {
      let length = match read_length(reader) {
        Ok(value) => value
        Err(err) => return Err(err)
      }
      if length > limits.max_value_bytes {
        return Err(DecodeError::LimitExceeded("byte value length"))
      }
      match reader.read_bytes(length) {
        Ok(value) => Ok(BinValue::Bytes(value))
        Err(err) => Err(err)
      }
    }
    TAG_ARRAY => {
      let count = match read_length(reader) {
        Ok(value) => value
        Err(err) => return Err(err)
      }
      if count > limits.max_collection_items {
        return Err(DecodeError::LimitExceeded("array item count"))
      }
      if count > reader.remaining() {
        return Err(
          DecodeError::InvalidLength("array count exceeds remaining bytes"),
        )
      }
      let values : Array[BinValue] = []
      for _ in 0..<count {
        match decode_from(reader, limits, depth + 1) {
          Ok(value) => values.push(value)
          Err(err) => return Err(err)
        }
      }
      Ok(BinValue::Array(values))
    }
    TAG_OBJECT => {
      let count = match read_length(reader) {
        Ok(value) => value
        Err(err) => return Err(err)
      }
      if count > limits.max_collection_items {
        return Err(DecodeError::LimitExceeded("object entry count"))
      }
      if count > reader.remaining() / 5 {
        return Err(
          DecodeError::InvalidLength("object count exceeds remaining bytes"),
        )
      }
      let entries : Array[(String, BinValue)] = []
      for _ in 0..<count {
        let key_length = match read_length(reader) {
          Ok(value) => value
          Err(err) => return Err(err)
        }
        if key_length > limits.max_value_bytes {
          return Err(DecodeError::LimitExceeded("object key byte length"))
        }
        let key_bytes = match reader.read_bytes(key_length) {
          Ok(value) => value
          Err(err) => return Err(err)
        }
        let key = match decode_utf8(key_bytes) {
          Ok(value) => value
          Err(err) => return Err(err)
        }
        let value = match decode_from(reader, limits, depth + 1) {
          Ok(value) => value
          Err(err) => return Err(err)
        }
        entries.push((key, value))
      }
      Ok(BinValue::Object(entries))
    }
    _ => Err(DecodeError::InvalidTag(tag))
  }
}

///|
/// Decodes exactly one moonbin v1 value using explicit resource limits.
///
/// The function rejects unread trailing bytes after the top-level value.
pub fn decode_with_limits(
  bytes : Bytes,
  limits : DecodeLimits,
) -> Result[BinValue, DecodeError] {
  if limits.max_depth < 0 ||
    limits.max_collection_items < 0 ||
    limits.max_value_bytes < 0 {
    return Err(DecodeError::InvalidLength("decode limits must be non-negative"))
  }
  let reader = ByteReader::new(bytes)
  match decode_from(reader, limits, 0) {
    Err(err) => Err(err)
    Ok(value) =>
      if reader.remaining() == 0 {
        Ok(value)
      } else {
        Err(DecodeError::TrailingBytes(reader.remaining()))
      }
  }
}

///|
/// Decodes exactly one moonbin v1 value using conservative default limits.
pub fn decode(bytes : Bytes) -> Result[BinValue, DecodeError] {
  decode_with_limits(bytes, default_decode_limits())
}
