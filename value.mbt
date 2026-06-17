///|
/// Core moonbin value model.
///
/// `BinValue` is the stable intermediate representation that moonbin v1
/// encodes to bytes and decodes from bytes. User-defined structs can be mapped
/// to this model explicitly without relying on runtime reflection.
pub enum BinValue {
  Null
  Bool(Bool)
  Int(Int)
  Double(Double)
  String(String)
  Bytes(Bytes)
  Array(Array[BinValue])
  Object(Array[(String, BinValue)])
}

///|
/// Returns the human-readable kind name of a `BinValue`.
pub fn BinValue::kind(self : BinValue) -> String {
  match self {
    Null => "null"
    Bool(_) => "bool"
    Int(_) => "int"
    Double(_) => "double"
    String(_) => "string"
    Bytes(_) => "bytes"
    Array(_) => "array"
    Object(_) => "object"
  }
}
