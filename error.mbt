///|
/// Decode errors returned by moonbin readers and decoders.
///
/// The first version keeps errors small and explicit. Later decoder modules can
/// attach these variants to concrete byte-reading and type-checking failures.
pub(all) enum DecodeError {
  UnexpectedEOF
  InvalidTag(Int)
  InvalidType(String, String)
  InvalidLength(String)
  TrailingBytes(Int)
} derive(Eq, Debug)

///|
/// Returns a stable category name for a decode error.
pub fn DecodeError::kind(self : DecodeError) -> String {
  match self {
    UnexpectedEOF => "unexpected_eof"
    InvalidTag(_) => "invalid_tag"
    InvalidType(_, _) => "invalid_type"
    InvalidLength(_) => "invalid_length"
    TrailingBytes(_) => "trailing_bytes"
  }
}

///|
/// Returns a short human-readable message for a decode error.
pub fn DecodeError::message(self : DecodeError) -> String {
  match self {
    UnexpectedEOF => "input ended before the required bytes were available"
    InvalidTag(tag) => "invalid moonbin type tag: \{tag}"
    InvalidType(expected, actual) =>
      "expected \{expected}, but decoded \{actual}"
    InvalidLength(reason) => "invalid length: \{reason}"
    TrailingBytes(count) => "trailing bytes after top-level value: \{count}"
  }
}
