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

**Hash：** 本次提交完成后以 `git log` 为准。

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

## 后续维护说明

后续每个有效 commit 都应继续追加一节，记录：

- commit hash
- commit message
- 目的
- 主要变更
- 为什么这次提交是有效开发内容
