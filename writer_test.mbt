///|
test "byte writer starts empty" {
  let writer = ByteWriter::new()
  inspect(writer.len(), content="0")
  inspect(writer.is_empty(), content="true")
}

///|
test "byte writer tracks written bytes" {
  let writer = ByteWriter::new()
  inspect(writer.write_u8(1), content="true")
  inspect(writer.write_u8(255), content="true")
  inspect(writer.len(), content="2")
  inspect(writer.is_empty(), content="false")
}

///|
test "byte writer rejects invalid u8 values" {
  let writer = ByteWriter::new()
  inspect(writer.write_u8(-1), content="false")
  inspect(writer.write_u8(256), content="false")
  inspect(writer.len(), content="0")
}
