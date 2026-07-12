# moonbin

moonbin 是一个面向 MoonBit 的轻量级二进制序列化与反序列化库。

项目第一版聚焦于一件事：

```text
BinValue <-> Bytes
```

moonbin 会定义一套紧凑、可文档化、可测试的自定义二进制格式，用于表示常见结构化数据。它不依赖运行时反射，不实现 protobuf，也不重复 MoonBit 官方 JSON 能力。

## 当前范围

- 提供 `BinValue` 通用数据模型和 `DecodeError` 错误模型
- 实现 moonbin v1 二进制格式
- 支持 Null、Bool、Int、Double、String 和 Bytes
- 支持 Array 和 Object 的递归编解码
- 对非法标签、非法 Bool、截断输入、非法 UTF-8 和尾随字节返回明确错误

用户自定义结构体可以通过显式转换函数接入：

```text
User <-> BinValue <-> Bytes
```

## 快速使用

```moonbit
let value = BinValue::Object([
  ("name", BinValue::String("Hou")),
  ("age", BinValue::Int(18)),
])
let bytes = encode(value)
let decoded = decode(bytes)
```

运行仓库内的完整示例：

```bash
moon run cmd/demo
```

## 文档

- [二进制格式说明](docs/format.md)
- [提交记录](docs/commit-log.md)
