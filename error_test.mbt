///|
test "decode error kind names" {
  inspect(DecodeError::UnexpectedEOF.kind(), content="unexpected_eof")
  inspect(DecodeError::InvalidTag(255).kind(), content="invalid_tag")
  inspect(
    DecodeError::InvalidType("string", "int").kind(),
    content="invalid_type",
  )
  inspect(
    DecodeError::InvalidLength("negative length").kind(),
    content="invalid_length",
  )
  inspect(DecodeError::TrailingBytes(3).kind(), content="trailing_bytes")
}

///|
test "decode error messages" {
  inspect(
    DecodeError::UnexpectedEOF.message(),
    content="input ended before the required bytes were available",
  )
  inspect(
    DecodeError::InvalidTag(9).message(),
    content="invalid moonbin type tag: 9",
  )
  inspect(
    DecodeError::InvalidType("bool", "string").message(),
    content="expected bool, but decoded string",
  )
  inspect(
    DecodeError::InvalidLength("not enough payload bytes").message(),
    content="invalid length: not enough payload bytes",
  )
  inspect(
    DecodeError::TrailingBytes(2).message(),
    content="trailing bytes after top-level value: 2",
  )
}
