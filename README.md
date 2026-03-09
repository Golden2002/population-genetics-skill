# Population Genetics Assistant

> 群体遗传学专家助手 - 基于Claude的智能分析助手

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0-green.svg)](SKILL.md)

## 📖 项目简介

Population Genetics Assistant 是一款专为群体遗传学研究者设计的Claude Skill（技能），旨在帮助研究人员更高效地完成群体遗传学数据分析工作。

无论你是：
- 刚入门群体遗传学的研究生
- 需要处理大量数据的科研人员
- 希望自动化分析流程的博士后

这个助手都能为你提供强大的支持！

## ✨ 核心功能

### 1. 🔍 智能分析与推荐
- 根据研究目的推荐合适的分析方法和软件工具
- 提供多种分析方案的优缺点比较

### 2. 📚 软件学习指导
- 检索和分析相关软件论文、官方文档、教程
- 教授软件原理和使用方法
- 展示可视化效果示例

### 3. 💻 脚本编写
- 基于你的工作流习惯编写可直接运行的Slurm/Bash脚本
- 自动适配你的计算环境和参数偏好

### 4. 📊 结果解读
- 帮助理解输出文件格式（VCF, PLINK, Admixture等）
- 进行数据统计和处理操作
- 单倍型分型结果解读

### 5. 🎓 原理教学
- 群体遗传学基础概念（Fst, Tajima's D, iHS, LD等）
- 统计方法原理（EM算法、贝叶斯推断、PCA等）
- 计算机基础（二进制格式、并行计算等）

### 6. 🧪 实验设计
- 背景人群选择建议
- 样本量设计
- 分析策略讨论

### 7. 📥 数据获取
- 公共数据库使用指导（1000 Genomes, TOPMed, gnomAD等）
- 数据下载和预处理

### 8. 🔬 高级分析
- GWAS全基因组关联分析
- 变异注释（SnpEff, VEP, ANNOVAR）
- 功能富集分析

### 9. 📈 结果展示
- 论文级图表准备
- 可视化R/Python代码

## 🛠️ 支持的分析类型

| 分析类型 | 支持的软件/方法 |
|---------|---------------|
| 群体结构 | PCA, Admixture, fineSTRUCTURE |
| 选择信号 | Fst, Tajima's D, iHS, XP-EHH, CLR, ROH |
| 单倍型分析 | ShapeIt4, Beagle, ChromoPainter |
| 群体历史 | MSMC, SMC++, Treemix |
| 系统发育 | IQ-TREE, MEGA, RAxML |
| GWAS | PLINK, REGENIE, SAIGE |

## 📦 安装方式

### 方式一：直接复制

1. 克隆或下载本仓库
2. 将 `SKILL.md` 文件复制到你的Claude Skills目录：
   ```
   ~/.claude/skills/population-genetics/
   ```
3. 重命名为 `SKILL.md`

### 方式二：创建目录结构

```bash
# 创建技能目录
mkdir -p ~/.claude/skills/population-genetics

# 将文件放入目录
# (复制 SKILL.md 和其他文件)
```

## 🚀 使用方式

### 启动助手

在Claude中，直接描述你的分析需求，例如：

```
我想做群体结构分析
```

```
帮我写一个Admixture分析的脚本
```

```
什么是Tajima's D？它的数学原理是什么？
```

```
帮我解释一下Admixture的.Q文件格式
```

### 自动学习你的脚本

如果你有自己的分析脚本，可以告诉助手：

```
请学习我的脚本，提取工作流配置信息
```

助手会：
1. 读取 `scripts/` 目录下的脚本
2. 提取配置信息（路径、参数等）
3. 生成 `examples/user_workflow_memory.md` 供后续使用

## ⚙️ 配置说明

### 用户工作流记忆

Skill包含可扩展的配置模块，你可以自定义：

- 基础配置（Shebang、集群系统、计算资源）
- 目录结构（项目目录、数据目录）
- 软件路径（PLINK、ADMIXTURE等）
- 分析参数（MAF阈值、K值范围等）
- 数据路径（VCF文件、样本列表等）

详见 [SKILL.md](SKILL.md) 中的「用户工作流记忆」部分。

### 目录结构

```
population-genetics/
├── SKILL.md              # 主技能文件
├── scripts/              # 你的分析脚本（可选）
│   ├── analysis1.sh
│   └── analysis2.sh
└── examples/             # 提取的工作流配置（自动生成）
    └── user_workflow_memory.md
```

## 📝 示例脚本

本仓库包含示例脚本，供参考：

- `scripts/admixture_pipeline.sh` - Admixture分析流程示例
- `scripts/diversity_analysis.sh` - 遗传多样性分析示例
- `examples/user_workflow_memory.md` - 工作流配置示例

**注意**：示例脚本已去除敏感信息，使用时请替换为实际路径。

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 开启Pull Request

## 📋 更新日志

### v2.0 (2024-03)
- 新增自动学习用户脚本功能
- 扩展工作流记忆模块
- 新增数据获取和高级分析模块
- 优化结果展示和论文图表部分

### v1.0 (2024-01)
- 初始版本
- 基础分析功能和脚本编写

## 📞 联系方式

- 问题反馈：[GitHub Issues](https://github.com/yourusername/population-genetics-assistant/issues)
- 功能建议：[GitHub Issues](https://github.com/yourusername/population-genetics-assistant/issues)

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

**Made with ❤️ for Population Genetics Researchers**
