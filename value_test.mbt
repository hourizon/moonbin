///|
test "binvalue primitive kind names" {
  inspect(BinValue::Null.kind(), content="null")
  inspect(BinValue::Bool(true).kind(), content="bool")
  inspect(BinValue::Int(1).kind(), content="int")
  inspect(BinValue::Double(1.5).kind(), content="double")
  inspect(BinValue::String("moonbin").kind(), content="string")
}

///|
test "binvalue compound kind names" {
  inspect(BinValue::Array([]).kind(), content="array")
  inspect(BinValue::Object([]).kind(), content="object")
}

///|
test "represent user as binvalue object" {
  let user = BinValue::Object([
    ("name", BinValue::String("Hou")),
    ("age", BinValue::Int(18)),
  ])
  inspect(user.kind(), content="object")
}
