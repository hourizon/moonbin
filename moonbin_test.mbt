///|
test "version" {
  inspect(version(), content="0.1.0")
}

///|
test "value model name" {
  inspect(value_model_name(), content="BinValue")
}

///|
test "binvalue kind names" {
  inspect(BinValue::Null.kind(), content="null")
  inspect(BinValue::Bool(true).kind(), content="bool")
  inspect(BinValue::Int(1).kind(), content="int")
  inspect(BinValue::Double(1.5).kind(), content="double")
  inspect(BinValue::String("moonbin").kind(), content="string")
  inspect(BinValue::Array([]).kind(), content="array")
  inspect(BinValue::Object([]).kind(), content="object")
}

///|
test "error model name" {
  inspect(error_model_name(), content="DecodeError")
}

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
