///|
test "version" {
  inspect(version(), content="0.1.0")
}

///|
test "model names" {
  inspect(value_model_name(), content="BinValue")
  inspect(error_model_name(), content="DecodeError")
}
