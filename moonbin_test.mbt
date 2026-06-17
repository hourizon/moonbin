test "version" {
  inspect(version(), content="0.1.0")
}

test "value model name" {
  inspect(value_model_name(), content="BinValue")
}

test "binvalue kind names" {
  inspect(BinValue::Null.kind(), content="null")
  inspect(BinValue::Bool(true).kind(), content="bool")
  inspect(BinValue::Int(1).kind(), content="int")
  inspect(BinValue::Double(1.5).kind(), content="double")
  inspect(BinValue::String("moonbin").kind(), content="string")
  inspect(BinValue::Array([]).kind(), content="array")
  inspect(BinValue::Object([]).kind(), content="object")
}
