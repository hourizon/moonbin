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
  inspect(
    writer.to_bytes(),
    content=(
      #|b"\x01\xff"
    ),
  )
}

///|
test "byte writer rejects invalid u8 values" {
  let writer = ByteWriter::new()
  inspect(writer.write_u8(-1), content="false")
  inspect(writer.write_u8(256), content="false")
  inspect(writer.len(), content="0")
}

///|
test "byte writer writes big-endian numbers" {
  let writer = ByteWriter::new()
  writer.write_u32(0x01020304U)
  writer.write_i64(0x0102030405060708L)
  writer.write_f64(1.0)
  inspect(
    writer.to_bytes(),
    content=(
      #|b"\x01\x02\x03\x04\x01\x02\x03\x04\x05\x06\x07\x08?\xf0\x00\x00\x00\x00\x00\x00"
    ),
  )
}

///|
test "byte writer appends raw bytes" {
  let writer = ByteWriter::new()
  writer.write_bytes(b"moon")
  inspect(
    writer.to_bytes(),
    content=(
      #|b"moon"
    ),
  )
}
