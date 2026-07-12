///|
test "byte reader starts at position zero" {
  let reader = ByteReader::new(b"\x01\x02\x03")
  inspect(reader.len(), content="3")
  inspect(reader.position(), content="0")
  inspect(reader.remaining(), content="3")
  inspect(reader.is_empty(), content="false")
}

///|
test "byte reader reads u8 values in order" {
  let reader = ByteReader::new(b"\x07\x08")
  match reader.read_u8() {
    Ok(value) => inspect(value, content="7")
    Err(_) => fail("expected first byte")
  }
  inspect(reader.position(), content="1")
  inspect(reader.remaining(), content="1")
  match reader.read_u8() {
    Ok(value) => inspect(value, content="8")
    Err(_) => fail("expected second byte")
  }
  inspect(reader.position(), content="2")
  inspect(reader.remaining(), content="0")
  inspect(reader.is_empty(), content="true")
}

///|
test "byte reader returns eof on empty input" {
  let reader = ByteReader::new(b"")
  match reader.read_u8() {
    Ok(_) => fail("expected eof")
    Err(err) => inspect(err.kind(), content="unexpected_eof")
  }
  inspect(reader.position(), content="0")
}

///|
test "byte reader returns eof after consuming all input" {
  let reader = ByteReader::new(b"\xFF")
  match reader.read_u8() {
    Ok(value) => inspect(value, content="255")
    Err(_) => fail("expected byte")
  }
  match reader.read_u8() {
    Ok(_) => fail("expected eof")
    Err(err) => inspect(err.kind(), content="unexpected_eof")
  }
  inspect(reader.position(), content="1")
}

///|
test "byte reader reads big-endian numbers" {
  let reader = ByteReader::new(
    b"\x01\x02\x03\x04\x01\x02\x03\x04\x05\x06\x07\x08\x3F\xF0\x00\x00\x00\x00\x00\x00",
  )
  match reader.read_u32() {
    Ok(value) => inspect(value, content="16909060")
    Err(_) => fail("expected u32")
  }
  match reader.read_i64() {
    Ok(value) => inspect(value, content="72623859790382856")
    Err(_) => fail("expected i64")
  }
  match reader.read_f64() {
    Ok(value) => inspect(value, content="1")
    Err(_) => fail("expected f64")
  }
}

///|
test "byte reader reads raw bytes" {
  let reader = ByteReader::new(b"moonbin")
  match reader.read_bytes(4) {
    Ok(value) =>
      inspect(
        value,
        content=(
          #|b"moon"
        ),
      )
    Err(_) => fail("expected raw bytes")
  }
  inspect(reader.remaining(), content="3")
}

///|
test "byte reader preserves position on failed fixed-width read" {
  let reader = ByteReader::new(b"\x01\x02\x03")
  match reader.read_u32() {
    Ok(_) => fail("expected eof")
    Err(err) => inspect(err.kind(), content="unexpected_eof")
  }
  inspect(reader.position(), content="0")
}
