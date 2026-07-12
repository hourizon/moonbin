///|
priv struct User {
  name : String
  age : Int
} derive(Eq)

///|
fn User::to_bin(self : User) -> BinValue {
  BinValue::Object([
    ("name", BinValue::String(self.name)),
    ("age", BinValue::Int(self.age)),
  ])
}

///|
fn User::from_bin(value : BinValue) -> Result[User, DecodeError] {
  match value {
    BinValue::Object(
      [("name", BinValue::String(name)), ("age", BinValue::Int(age))]
    ) => Ok({ name, age })
    other => Err(DecodeError::InvalidType("User object", other.kind()))
  }
}

///|
test "user struct roundtrips through BinValue" {
  let user : User = { name: "Hou", age: 18 }
  let decoded = match decode(encode(user.to_bin())) {
    Ok(value) => value
    Err(_) => fail("moonbin decode failed")
  }
  assert_true(User::from_bin(decoded) == Ok(user))
}

///|
test "user adapter rejects an incompatible BinValue" {
  assert_true(
    User::from_bin(BinValue::String("not a user")) ==
    Err(DecodeError::InvalidType("User object", "string")),
  )
}
