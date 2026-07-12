# moonbin 提交记录

本文档记录 moonbin 仓库中每一次有效 commit 的目的和主要变更，用于保留项目开发过程，满足 OSC2026 申报中对真实、连续、可追踪提交记录的要求。

## Commit 1

**Hash：** `f7f9f24`

**Message：** `Initialize MoonBit project structure`

**目的：** 初始化最小 MoonBit 包结构，让后续工作基于真实项目推进，而不是停留在零散文档。

**主要变更：**

- 新增 `.gitignore`，忽略 MoonBit 构建产物、编辑器文件和系统文件。
- 新增 `README.md`，作为 GitHub 仓库首页说明。
- 新增 `README.mbt.md`，作为 MoonBit 文档和示例测试入口。
- 新增 `moon.mod`，作为 MoonBit 模块级配置。
- 新增 `moon.pkg`，作为包级配置。
- 新增 `moonbin.mbt`，提供最小公开 API `version()`。
- 新增 `moonbin_test.mbt`，提供基础版本测试。

## Commit 2

**Hash：** `8de6ac4`

**Message：** `Add project proposal and planning notes`

**目的：** 加入项目申报书和早期规划材料，记录项目方向、定位和设计依据。

**主要变更：**

- 新增 `moonbin_project_proposal.md`，作为项目申报书草稿。
- 新增 `moonbit_moonbin_project_discussion.md`，作为早期讨论整理。

## Commit 3

**Hash：** `f32d3fe`

**Message：** `Remove planning discussion notes`

**目的：** 从公开仓库中移除过于宽泛的讨论文档，让仓库更聚焦于项目本身和申报材料。

**主要变更：**

- 删除 `moonbit_moonbin_project_discussion.md`。

## Commit 4

**Hash：** `b758968`

**Message：** `Add moonbin binary format specification`

**目的：** 在实现编码器和解码器之前，先定义 moonbin 第一版二进制格式。

**主要变更：**

- 新增 `docs/format.md`。
- 明确 v1 核心范围为 `BinValue <-> Bytes`。
- 明确非目标：不依赖运行时反射、不做 schema 文件、不做代码生成、不兼容 protobuf、不自动序列化任意 MoonBit struct。
- 定义 `BinValue` 数据模型。
- 定义通用二进制布局：`Tag + Payload` 和 `Tag + Length + Value`。
- 定义 Null、Bool、Int、Double、String、Bytes、Array、Object 的类型 Tag。
- 定义基础类型和复合类型编码规则。
- 添加 Bool、String、Array、Object 的字节级示例。
- 说明解码规则、错误模型、兼容性规则以及与 MoonBit JSON 能力的关系。

## Commit 5

**Hash：** `67167ca`

**Message：** `Add commit history record`

**目的：** 新增仓库内维护的开发记录，解释每个有效 commit 的意义。

**主要变更：**

- 新增 `docs/commit-log.md`。
- 记录项目初始化 commit。
- 记录项目申报材料 commit。
- 记录删除早期讨论文档的清理 commit。
- 记录二进制格式说明文档 commit。
- 添加后续维护说明。

## Commit 6

**Hash：** `ab0b71b`

**Message：** `Define BinValue core data model`

**目的：** 加入后续编码器和解码器都会依赖的核心数据模型。

**主要变更：**

- 新增 `value.mbt`。
- 定义公开的 `BinValue` 枚举，包含 Null、Bool、Int、Double、String、Bytes、Array、Object 等变体。
- 新增 `BinValue::kind()`，便于测试和调试。
- 新增 `value_model_name()`，暴露当前核心数据模型名称。
- 扩展测试，覆盖数据模型名称和代表性 `BinValue` 类型名称。

## Commit 7

**Hash：** `7adbe32`

**Message：** `Define DecodeError model`

**目的：** 加入后续 reader 和 decoder 模块都会使用的统一解码错误模型。

**主要变更：**

- 新增 `error.mbt`。
- 定义 `DecodeError` 枚举，覆盖 UnexpectedEOF、InvalidTag、InvalidType、InvalidLength、TrailingBytes。
- 新增 `DecodeError::kind()`，提供稳定错误分类名称。
- 新增 `DecodeError::message()`，提供简短可读错误信息。
- 新增 `error_model_name()`，暴露当前错误模型名称。
- 扩展测试，覆盖错误模型名称、错误分类和错误信息。
- 调整 `BinValue` 枚举可见性，使测试和后续模块可以构造 `BinValue`。
- 更新忽略规则，忽略 MoonBit 测试产生的 `_build/` 目录。

## Commit 8

**Hash：** `990e6ab`

**Message：** `Add usage examples and split tests`

**目的：** 整理当前测试结构，并补充 README 示例，让后续模块开发有清晰的测试落点和使用说明。

**主要变更：**

- 扩充 `README.mbt.md`，加入基础值、结构化数据和错误模型示例。
- 简化 `moonbin_test.mbt`，只保留版本和模型名称等入口层测试。
- 新增 `value_test.mbt`，集中测试 `BinValue` 相关行为。
- 新增 `error_test.mbt`，集中测试 `DecodeError` 相关行为。
- 增加用户对象映射为 `BinValue::Object` 的示例测试。

## Commit 9

**Hash：** `efdff9b`

**Message：** `Add ByteWriter module skeleton`

**目的：** 加入后续编码器会使用的最小字节写入器框架，为 `BinValue -> Bytes` 编码方向搭建底层模块。

**主要变更：**

- 新增 `writer.mbt`。
- 定义 `ByteWriter` 结构体，暂时用 `Array[Int]` 保存 0 到 255 范围内的字节值。
- 新增 `ByteWriter::new()`、`len()`、`is_empty()` 和 `write_u8()`。
- 新增 `writer_test.mbt`。
- 测试空 writer、成功写入合法 u8、拒绝非法 u8 以及长度统计。

## Commit 10

**Hash：** `fd26cc4`

**Message：** `Add ByteReader module skeleton`

**目的：** 加入后续解码器会使用的最小字节读取器框架，为 `Bytes -> BinValue` 解码方向搭建底层模块。

**主要变更：**

- 新增 `reader.mbt`。
- 定义 `ByteReader` 结构体，暂时从 `Array[Int]` 读取字节值，并维护读取位置。
- 新增 `ByteReader::new()`、`len()`、`position()`、`remaining()`、`is_empty()` 和 `read_u8()`。
- 新增 `reader_test.mbt`。
- 测试初始位置、顺序读取、剩余长度变化以及空输入返回 `UnexpectedEOF`。

## Commit 11

**Hash：** `c4df95f`

**Message：** `Add MIT license`

**目的：** 为项目补充 OSI 认可的项目级开源许可证，明确代码使用、修改和分发规则。

**主要变更：**

- 在仓库根目录新增 `LICENSE`。
- 许可证与 `moon.mod` 中声明的 MIT 保持一致。

## Commit 12

**Hash：** `e44e1b8`

**Message：** `Upgrade byte reader and writer primitives`

**目的：** 将临时字节骨架升级为基于 MoonBit 官方 `Bytes` 和 `Buffer` 的正式字节读写层，为编解码器提供稳定底座。

**主要变更：**

- `ByteWriter` 改用 `@buffer.Buffer` 保存真实字节。
- 支持 big-endian u32、i64、f64 和原始 Bytes 写入。
- `ByteReader` 改为直接读取 `Bytes`。
- 支持 big-endian u32、i64、f64 和定长原始 Bytes 读取。
- 增加截断输入不推进读取位置等边界测试。
- 严格模式下通过 `moon check --deny-warn` 和 `moon test --deny-warn`。

## Commit 13

**Hash：** `538fb38`

**Message：** `Implement BinValue binary codec`

**目的：** 完成 moonbin v1 从通用数据模型到二进制字节的核心闭环，使项目从底层读写框架进入可实际使用的编解码阶段。

**主要变更：**

- 新增 `codec.mbt`，实现 `encode()` 和 `decode()` 公共 API。
- 为 Null、Bool、Int、Double、String、Bytes、Array 和 Object 实现确定性的 big-endian 编码。
- 支持 Array 和 Object 的递归编解码，并保持对象条目顺序。
- 对非法标签、非法 Bool、截断输入、非法 UTF-8、异常长度和尾随字节返回明确错误。
- 新增 `codec_test.mbt`，覆盖固定字节布局、基础类型与复合类型往返、错误输入。
- 更新 README，加入当前能力和最小编解码示例。
- 严格模式下通过 `moon check --deny-warn` 和 `moon test --deny-warn`。

## Commit 14

**Hash：** 本次提交完成后以 `git log` 为准。

**Message：** `Add runnable demo and continuous integration`

**目的：** 提供可直接运行的项目入口，并让代码格式、编译、测试和示例在每次推送时自动接受验证。

**主要变更：**

- 新增 `cmd/demo` 主包，通过 `moon run cmd/demo` 展示 Object 的编码与解码。
- 新增 GitHub Actions CI，自动执行格式检查、严格 check、严格 build、严格 test 和 demo。
- 更新 README，加入 demo 运行命令。

## 后续维护说明

后续每个有效 commit 都应继续追加一节，记录：

- commit hash
- commit message
- 目的
- 主要变更
- 为什么这次提交是有效开发内容
