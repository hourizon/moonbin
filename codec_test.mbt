///|
fn assert_roundtrip(value : BinValue) -> Unit raise {
  assert_true(decode(encode(value)) == Ok(value))
}

///|
fn assert_decode(
  input : Bytes,
  expected : Result[BinValue, DecodeError],
) -> Unit raise {
  assert_true(decode(input) == expected)
}

///|
test "encode primitive wire bytes" {
  inspect(
    encode(BinValue::Null),
    content=(
      #|b"\x00"
    ),
  )
  inspect(
    encode(BinValue::Bool(true)),
    content=(
      #|b"\x01\x01"
    ),
  )
  inspect(
    encode(BinValue::Int(1)),
    content=(
      #|b"\x02\x00\x00\x00\x00\x00\x00\x00\x01"
    ),
  )
  inspect(
    encode(BinValue::Double(1.0)),
    content=(
      #|b"\x03?\xf0\x00\x00\x00\x00\x00\x00"
    ),
  )
  inspect(
    encode(BinValue::String("Hi")),
    content=(
      #|b"\x04\x00\x00\x00\x02Hi"
    ),
  )
  inspect(
    encode(BinValue::Bytes(b"\xAA\xBB")),
    content=(
      #|b"\x05\x00\x00\x00\x02\xaa\xbb"
    ),
  )
}

///|
test "primitive values roundtrip" {
  assert_roundtrip(BinValue::Null)
  assert_roundtrip(BinValue::Bool(false))
  assert_roundtrip(BinValue::Bool(true))
  assert_roundtrip(BinValue::Int(-42))
  assert_roundtrip(BinValue::Int(2147483647))
  assert_roundtrip(BinValue::Double(-3.5))
  assert_roundtrip(BinValue::String("hello, moonbin"))
  assert_roundtrip(BinValue::Bytes(b"\x00\x01\xff"))
}

///|
test "compound values roundtrip" {
  assert_roundtrip(
    BinValue::Array([
      BinValue::Bool(true),
      BinValue::Int(7),
      BinValue::String("nested"),
    ]),
  )
  assert_roundtrip(
    BinValue::Object([
      ("name", BinValue::String("Hou")),
      ("age", BinValue::Int(18)),
      ("flags", BinValue::Array([BinValue::Bool(true), BinValue::Null])),
    ]),
  )
}

///|
test "decode rejects malformed input" {
  assert_decode(b"\xFF", Err(DecodeError::InvalidTag(255)))
  assert_decode(
    b"\x01\x02",
    Err(DecodeError::InvalidType("bool payload 0 or 1", "invalid byte")),
  )
  assert_decode(b"\x02\x00", Err(DecodeError::UnexpectedEOF))
  assert_decode(b"\x00\x00", Err(DecodeError::TrailingBytes(1)))
}

///|
test "decode rejects invalid lengths and utf8" {
  assert_decode(b"\x04\x00\x00\x00\x02A", Err(DecodeError::UnexpectedEOF))
  assert_decode(
    b"\x04\x00\x00\x00\x01\xFF",
    Err(DecodeError::InvalidType("valid UTF-8", "malformed bytes")),
  )
  assert_decode(
    b"\x06\x00\x00\x00\x02\x00",
    Err(DecodeError::InvalidLength("array count exceeds remaining bytes")),
  )
}

///|
test "decode enforces resource limits" {
  let no_nesting : DecodeLimits = {
    max_depth: 0,
    max_collection_items: 10,
    max_value_bytes: 10,
  }
  assert_true(
    decode_with_limits(encode(BinValue::Array([BinValue::Null])), no_nesting) ==
    Err(DecodeError::LimitExceeded("maximum nesting depth")),
  )
  let one_byte_values : DecodeLimits = {
    max_depth: 10,
    max_collection_items: 10,
    max_value_bytes: 1,
  }
  assert_true(
    decode_with_limits(encode(BinValue::String("Hi")), one_byte_values) ==
    Err(DecodeError::LimitExceeded("string byte length")),
  )
  let no_items : DecodeLimits = {
    max_depth: 10,
    max_collection_items: 0,
    max_value_bytes: 10,
  }
  assert_true(
    decode_with_limits(encode(BinValue::Array([BinValue::Null])), no_items) ==
    Err(DecodeError::LimitExceeded("array item count")),
  )
}

///|
test "decode rejects negative resource limits" {
  let invalid : DecodeLimits = {
    max_depth: -1,
    max_collection_items: 0,
    max_value_bytes: 0,
  }
  assert_true(
    decode_with_limits(b"\x00", invalid) ==
    Err(DecodeError::InvalidLength("decode limits must be non-negative")),
  )
}
