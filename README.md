# moonbin

moonbin 是一个面向 MoonBit 的轻量级二进制序列化与反序列化库。

项目第一版聚焦于一件事：

```text
BinValue <-> Bytes
```

moonbin 会定义一套紧凑、可文档化、可测试的自定义二进制格式，用于表示常见结构化数据。它不依赖运行时反射，不实现 protobuf，也不重复 MoonBit 官方 JSON 能力。

## 当前范围

- 定义 `BinValue` 通用数据模型
- 定义 `DecodeError` 错误模型
- 设计 moonbin v1 二进制格式
- 为后续 `ByteWriter`、`ByteReader`、编码器和解码器搭建项目框架

用户自定义结构体可以通过显式转换函数接入：

```text
User <-> BinValue <-> Bytes
```

## 文档

- [二进制格式说明](docs/format.md)
- [提交记录](docs/commit-log.md)
