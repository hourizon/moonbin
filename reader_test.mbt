///|
test "byte reader starts at position zero" {
  let reader = ByteReader::new([1, 2, 3])
  inspect(reader.len(), content="3")
  inspect(reader.position(), content="0")
  inspect(reader.remaining(), content="3")
  inspect(reader.is_empty(), content="false")
}

///|
test "byte reader reads u8 values in order" {
  let reader = ByteReader::new([7, 8])
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
  let reader = ByteReader::new([])
  match reader.read_u8() {
    Ok(_) => fail("expected eof")
    Err(err) => inspect(err.kind(), content="unexpected_eof")
  }
  inspect(reader.position(), content="0")
}

///|
test "byte reader returns eof after consuming all input" {
  let reader = ByteReader::new([255])
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
