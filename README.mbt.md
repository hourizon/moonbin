# moonbin

moonbin 第一版以 `BinValue` 作为核心数据模型，编码器和解码器围绕：

```text
BinValue <-> Bytes
```

展开。

## 编解码示例

```moonbit nocheck
///|
test "encode and decode a value" {
  let value = BinValue::Object([
    ("name", BinValue::String("Hou")),
    ("age", BinValue::Int(18)),
  ])
  let bytes = encode(value)
  assert_true(decode(bytes) == Ok(value))
}
```

## 基础值示例

```moonbit nocheck
///|
test "create primitive bin values" {
  inspect(BinValue::Null.kind(), content="null")
  inspect(BinValue::Bool(true).kind(), content="bool")
  inspect(BinValue::Int(42).kind(), content="int")
  inspect(BinValue::Double(3.14).kind(), content="double")
  inspect(BinValue::String("moonbin").kind(), content="string")
}
```

## 结构化数据示例

用户结构体第一版可以手写转换为 `BinValue::Object`，避免依赖运行时反射：

```moonbit nocheck
///|
test "represent user as bin value" {
  let user = BinValue::Object([
    ("name", BinValue::String("Hou")),
    ("age", BinValue::Int(18)),
  ])
  inspect(user.kind(), content="object")
}
```

## 错误模型示例

```moonbit nocheck
///|
test "decode error categories" {
  inspect(DecodeError::UnexpectedEOF.kind(), content="unexpected_eof")
  inspect(DecodeError::InvalidTag(255).kind(), content="invalid_tag")
}
```
