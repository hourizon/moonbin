///|
fn main {
  let value = @moonbin.BinValue::Object([
    ("name", @moonbin.BinValue::String("moonbin")),
    ("version", @moonbin.BinValue::Int(1)),
    (
      "features",
      @moonbin.BinValue::Array([
        @moonbin.BinValue::String("encode"),
        @moonbin.BinValue::String("decode"),
      ]),
    ),
  ])
  let bytes = @moonbin.encode(value)
  println("encoded byte length: \{bytes.length()}")
  match @moonbin.decode(bytes) {
    Ok(decoded) => println("decoded value kind: \{decoded.kind()}")
    Err(error) => println("decode failed: \{error.message()}")
  }
}
