# moonbin Binary Format

## 1. Goal

moonbin defines a lightweight binary format for structured MoonBit data.

The first version focuses on:

- `BinValue <-> Bytes`
- clear type tags
- deterministic encoding
- simple decoding rules
- explicit error handling

The first version does not include:

- runtime reflection
- schema files
- `.proto` parsing
- code generation
- protobuf wire format compatibility
- automatic serialization for arbitrary MoonBit structs

User-defined structs should be converted to `BinValue` explicitly before
encoding.

## 2. Data Model

The core data model is `BinValue`:

```moonbit
enum BinValue {
  Null
  Bool(Bool)
  Int(Int)
  Double(Double)
  String(String)
  Bytes(Bytes)
  Array(Array[BinValue])
  Object(Array[(String, BinValue)])
}
```

The binary format only needs to know how to encode and decode `BinValue`.
Business structs can be adapted with handwritten conversion functions:

```moonbit
user_to_bin(user : User) -> BinValue
user_from_bin(value : BinValue) -> Result[User, DecodeError]
```

## 3. General Layout

Each value starts with a one-byte type tag:

```text
Tag + Payload
```

For variable-length values, the payload contains a length field:

```text
Tag + Length + Value
```

Length fields use unsigned 32-bit integers in big-endian byte order.

Integer and floating-point payloads also use big-endian byte order. This keeps
encoded bytes deterministic across platforms and easy to document.

## 4. Type Tags

| Type | Tag |
|---|---:|
| Null | `0x00` |
| Bool | `0x01` |
| Int | `0x02` |
| Double | `0x03` |
| String | `0x04` |
| Bytes | `0x05` |
| Array | `0x06` |
| Object | `0x07` |

Tags outside this table are invalid in version 1.

## 5. Primitive Encoding

### Null

```text
0x00
```

Null has no payload.

### Bool

```text
0x01 + one byte
```

Payload:

| Value | Byte |
|---|---:|
| false | `0x00` |
| true | `0x01` |

Any other bool payload byte is invalid.

### Int

```text
0x02 + 8 bytes
```

Payload is a signed 64-bit integer in big-endian byte order.

Although MoonBit `Int` may be represented differently by backend, moonbin v1
uses a fixed 64-bit wire representation to keep the binary format stable.

### Double

```text
0x03 + 8 bytes
```

Payload is an IEEE 754 double-precision floating-point value in big-endian byte
order.

### String

```text
0x04 + length(u32) + UTF-8 bytes
```

The length is the number of UTF-8 bytes, not the number of characters.

An empty string is encoded with length `0`.

### Bytes

```text
0x05 + length(u32) + raw bytes
```

An empty byte array is encoded with length `0`.

## 6. Compound Encoding

### Array

```text
0x06 + count(u32) + item_0 + item_1 + ... + item_n
```

The count is the number of `BinValue` items.

Each array item is encoded as a complete `BinValue`, including its own tag.

An empty array is encoded with count `0`.

### Object

```text
0x07 + count(u32) + entry_0 + entry_1 + ... + entry_n
```

The count is the number of key-value entries.

Each entry is encoded as:

```text
key_length(u32) + key_utf8_bytes + value(BinValue)
```

Object keys are UTF-8 strings.

Object entry order is preserved. moonbin v1 does not sort keys or reject
duplicate keys. Users who need canonical object encoding can sort entries before
encoding.

An empty object is encoded with count `0`.

## 7. Examples

### Bool

```text
Bool(true)
= 01 01
```

### String

```text
String("Hi")
= 04 00 00 00 02 48 69
```

Explanation:

```text
04          tag: String
00 00 00 02 length: 2 bytes
48 69       UTF-8 bytes for "Hi"
```

### Array

```text
Array([Bool(true), Int(1)])
= 06 00 00 00 02 01 01 02 00 00 00 00 00 00 00 01
```

Explanation:

```text
06                         tag: Array
00 00 00 02                count: 2
01 01                      Bool(true)
02 00 00 00 00 00 00 00 01 Int(1)
```

### Object

```text
Object([("name", String("Hou")), ("age", Int(18))])
```

is encoded as:

```text
07
00 00 00 02
00 00 00 04 6e 61 6d 65 04 00 00 00 03 48 6f 75
00 00 00 03 61 67 65    02 00 00 00 00 00 00 00 12
```

## 8. Decode Rules

A decoder should:

1. Read one byte as the type tag.
2. Dispatch to the decoder for that tag.
3. Check required payload length before reading.
4. Decode nested values recursively for arrays and objects.
5. Report an error instead of silently ignoring malformed input.
6. After top-level decoding, reject trailing bytes unless the caller explicitly
   uses a streaming or partial decode API.

## 9. Error Model

moonbin v1 should define at least these decode errors:

| Error | Meaning |
|---|---|
| `UnexpectedEOF` | Input ended before the required bytes were available. |
| `InvalidTag` | The tag byte is not known in this format version. |
| `InvalidType` | A caller requested a specific type but the encoded value has another tag. |
| `InvalidLength` | A length or count field is invalid for the current input. |
| `TrailingBytes` | Top-level decode completed but unread bytes remained. |

## 10. Compatibility Rules

Version 1 keeps the format intentionally small.

Future versions may add new tags, schema support, derive helpers, or streaming
decode APIs. Existing tags should not change meaning.

If a future decoder sees an unknown tag, it should return `InvalidTag`.

## 11. Relationship With JSON

MoonBit already provides JSON support. moonbin does not replace or reimplement
JSON.

The recommended architecture is:

```text
User <-> BinValue <-> Bytes
Json <-> BinValue <-> Bytes
```

`Json <-> BinValue` can be added as an adapter layer later. The core format
remains `BinValue <-> Bytes`.
