# moonbin 项目申报书

## 一、基本信息

**项目名称：** moonbin：面向 MoonBit 的轻量级二进制序列化与反序列化工具库

**参赛者：** 

**联系方式：** 

**GitHub 仓库链接：** 

**Gitlink 仓库链接：** 

**项目方向：** 系统能力与运行时框架 / 面向特定格式的序列化与反序列化工具

**是否为移植项目：** 否。本项目为原创项目，设计思路参考 protobuf、bincode 等二进制序列化工具的基本思想，但不移植其源码，也不以完整兼容 protobuf 为目标。

## 二、项目简介

moonbin 计划实现一个面向 MoonBit 生态的轻量级二进制序列化与反序列化工具库。项目将设计一套简单、紧凑、可扩展的二进制编码格式，并以 `BinValue` 作为通用数据模型，支持 MoonBit 中常见基础类型与结构化数据在内存表示和字节序列之间进行双向转换。

相比 JSON 等文本格式，二进制序列化格式在数据体积和解析效率上具有优势，适合用于网络通信、本地缓存、数据交换、测试样例固化和运行时数据保存等场景。MoonBit 作为新兴编程语言，其生态仍需要更多基础工程工具支持。本项目希望补充 MoonBit 在结构化数据编码方向的基础能力，为后续 RPC、二进制协议解析、配置快照、跨模块数据交换等场景提供可复用组件。

本项目不会实现完整 protobuf，也不会引入复杂的 schema 编译、跨语言代码生成或运行时反射机制，而是完成一个适合 MoonBit 生态使用和展示的轻量级二进制序列化库。第一版项目不承诺自动遍历任意 MoonBit 结构体字段，而是优先实现 `BinValue <-> Bytes` 的稳定转换；用户自定义结构体可以通过手写转换函数或后续扩展的适配层转换为 `BinValue` 后再进行编码。

## 三、项目目标

moonbin 的核心目标是实现以下双向转换能力：

```text
MoonBit 数据 / BinValue  ->  二进制字节序列
二进制字节序列          ->  BinValue / MoonBit 数据
```

项目将围绕 `encode` 和 `decode` 两类能力展开，提供基础类型、复合类型、`BinValue` 通用表示、错误处理、格式文档、使用示例和自动化测试，形成一个可以公开发布、复用和维护的 MoonBit 包。

## 四、核心功能范围

1. 设计 moonbin 二进制编码格式，明确类型标记、长度编码、字段编码和错误处理规则。
2. 支持基础类型的编码与解码，包括 Bool、Int、Double、String、Bytes 等常见类型。
3. 支持数组、键值对象或结构化记录的编码与解码，能够通过 `BinValue` 表示嵌套数据结构。
4. 定义 `BinValue` 通用数据模型，用于统一表示 Null、Bool、Int、Double、String、Bytes、Array、Object 等 moonbin 可编码数据。
5. 提供统一 API，例如 `encode_bool`、`encode_int`、`encode_string`、`decode_bool`、`decode_int`、`decode_string`，以及 `encode(value : BinValue)`、`decode(bytes)` 等面向结构化数据的通用编码接口。
6. 提供用户结构体与 `BinValue` 之间的手写转换示例，说明在不依赖运行时反射的情况下如何编码业务数据。
7. 可选提供 `Json <-> BinValue` 适配层，利用 MoonBit 官方 JSON 能力作为输入输出桥接，但不重复实现 JSON 解析器。
8. 定义 DecodeError 错误类型，覆盖 UnexpectedEOF、InvalidType、InvalidLength、InvalidTag、TrailingBytes 等常见错误场景。
9. 提供格式说明文档，解释 moonbin 二进制格式的设计方式、编码示例和扩展规则。
10. 提供 README 示例，覆盖基础类型编码、结构化对象编码、字节序列解码、错误处理和典型使用场景。
11. 提供 MoonBit 测试用例，覆盖正常编码解码、嵌套数据、边界值、非法输入和错误提示。
12. 使用持续集成工具完成检查、构建和测试流程，保证项目可以稳定复现运行。
13. 在 GitHub 和 Gitlink 上保持同步更新，形成清晰、连续、可追踪的开发记录。

## 五、技术路线

moonbin 初步采用类似 TLV 的编码思路，即：

```text
Type + Length + Value
```

其中 Type 表示数据类型，Length 表示数据长度，Value 表示实际数据内容。基础类型可以使用固定或紧凑的编码方式，字符串、字节数组、数组和对象等变长数据则通过长度字段描述其内容边界。

初步类型标记设计如下：

| 类型 | Tag |
|---|---|
| Null | 0x00 |
| Bool | 0x01 |
| Int | 0x02 |
| Double | 0x03 |
| String | 0x04 |
| Bytes | 0x05 |
| Array | 0x06 |
| Object | 0x07 |

实现上将优先搭建 ByteWriter 和 ByteReader 两个基础组件，用于统一处理字节写入、读取、偏移推进、边界检查和错误返回。在此基础上逐步实现基础类型、复合类型和通用 `BinValue` 数据表示。由于 MoonBit 当前更适合通过静态类型、trait、derive 或手写函数组织序列化逻辑，moonbin 第一版不依赖运行时反射自动发现结构体字段，而是将 `BinValue` 作为稳定的中间层。

示例内部表示可以设计为：

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

并提供类似如下的通用接口：

```moonbit
encode(value : BinValue) -> Bytes
decode(bytes : Bytes) -> Result[BinValue, DecodeError]
```

对于用户自定义结构体，第一版推荐通过显式转换函数接入：

```moonbit
user_to_bin(user : User) -> BinValue
user_from_bin(value : BinValue) -> Result[User, DecodeError]
```

这种方式可以在不依赖反射的前提下保持实现简单、类型边界清晰，也便于后续扩展 derive、代码生成或 schema 描述能力。

## 六、项目创新点与生态价值

1. **贴合 MoonBit 生态需求**  
   MoonBit 生态仍处于快速发展阶段，基础工程库和可复用工具仍有补充空间。moonbin 可以作为结构化二进制数据处理方向的基础组件。

2. **方向清晰，边界可控**  
   本项目借鉴 protobuf 的结构化二进制编码思想，但不追求完整 protobuf 兼容，避免范围过大，保证在比赛周期内能够交付可运行成果。

3. **区别于已有 JSON 能力**  
   相比普通 JSON 序列化工具，moonbin 更强调紧凑二进制编码、错误处理和底层数据交换场景，具有更明显的差异化。

4. **便于测试和展示**  
   项目可以清楚展示“对象 -> 字节序列 -> 对象”的完整过程，也可以通过非法输入、边界值和嵌套结构测试体现工程质量。

5. **后续扩展空间明确**  
   后续可以继续扩展 schema 描述、版本兼容、更多数值类型、流式解码、性能基准测试、Json 适配层、derive 辅助或上层协议工具。

## 七、实施计划

**第一阶段：项目初始化与基础设计**

完成 MoonBit 项目结构搭建，添加 README 初稿、LICENSE、moonbin 二进制格式草案，定义 `BinValue`、类型标记和错误类型。

**第二阶段：基础编码解码能力**

实现 ByteWriter、ByteReader、Bool、Int、Double、String、Bytes 等基础类型的编码与解码，并补充基础单元测试。

**第三阶段：复合类型与错误处理**

实现数组、对象或结构化记录的编码与解码，支持 `BinValue` 嵌套数据结构，完善 UnexpectedEOF、InvalidType、InvalidLength、InvalidTag、TrailingBytes 等错误场景处理。

**第四阶段：文档、示例与工程化**

补充格式说明文档、README 使用示例、用户结构体手写转换示例、异常输入测试、边界测试和 CI 配置，整理项目交付材料，保持 GitHub 与 Gitlink 仓库同步。

## 八、最终交付物

项目最终将交付一个公开可访问的 MoonBit 开源仓库，包含：

1. 完整 MoonBit 源代码；
2. README 文档；
3. moonbin 二进制格式说明文档；
4. 基础类型和结构化数据编码示例；
5. 用户结构体与 `BinValue` 之间的转换示例；
6. 正常输入、边界输入和非法输入测试用例；
7. CI 检查、构建和测试配置；
8. 清晰、连续、真实有效的提交记录；
9. GitHub 与 Gitlink 同步仓库。

## 九、总结

moonbin 是一个面向 MoonBit 生态的轻量级二进制序列化与反序列化工具库。项目以可发布 MoonBit 包为目标，围绕 `BinValue` 通用数据模型、基础类型、结构化数据、二进制编码格式、错误处理、测试和文档形成完整交付。第一版不依赖运行时反射自动编码任意结构体，而是通过显式转换和清晰的数据模型保证范围可控、实现可靠。
