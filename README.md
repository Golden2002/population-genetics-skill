# Population Genetics Assistant (群体遗传学助手)

<p align="center">
  <img src="https://img.shields.io/badge/Claude-Skill-blue" alt="Claude Skill">
  <img src="https://img.shields.io/badge/Population-Genetics-green" alt="Population Genetics">
  <img src="https://img.shields.io/badge/Ancient--DNA-purple" alt="Ancient DNA">
  <img src="https://img.shields.io/badge/Chinese--friendly-orange" alt="Chinese Friendly">
</p>

## 简介

Population Genetics Assistant 是一款专为**群体遗传学研究者**设计的 Claude AI 助手技能 (Skill)，帮助你完成从数据分析到论文写作的全流程工作。

当你在与 Claude 对话中涉及以下内容时，此技能将**自动激活**：
- 群体结构分析 (PCA, Admixture, fineSTRUCTURE)
- 选择信号检测 (Fst, Tajima's D, iHS, XP-EHH)
- 古代DNA (aDNA) 分析与联合分析
- 古代渗入 (尼安德特人/丹尼索瓦人)
- 群体混合历史建模 (qpAdm, Multiwave2, TreeMix)
- IBD/ROH 亲缘关系分析
- 群体历史推断 (MSMC, SMC++)

---

## 核心功能

### 🧬 1. 智能需求分析

- 自动识别分析目的和需求
- 推荐最合适的方法与软件
- 提供实验设计建议

### 📚 2. 软件学习助手（强化版）

- **自动检索**官方文档、论文、教程
- 教授软件原理与使用方法
- 每次软件询问都会执行实际检索，确保信息最新

### 💻 3. 个性化脚本生成

- 基于你的工作流配置自动生成
- 支持 SLURM 集群脚本
- 支持批量分析、染色体循环、数组任务等模式

### 📊 4. 结果解读

- 各种文件格式说明 (VCF, PLINK, EIGENSTRAT, Admixture, IBD等)
- 统计结果解读
- 数据处理操作示例

### 🔬 5. 高级分析方法（新增）

| 分析类型 | 支持软件/方法 |
|----------|---------------|
| **古代DNA** | mapDamage, 联合PCA/Admixture |
| **古代渗入** | ArchaicSeeker2, ArchaicSeek, MSMC |
| **混合建模** | qpAdm, Multiwave2, TreeMix, f3/f4-statistics |
| **群体历史** | MSMC2, SMC++, Treemix |

### 🛠️ 6. 完整错误处理

- 常见错误排查
- 古DNA/渗入分析特有错误
- 调试技巧与日志分析

---

## 支持的分析场景

- ✅ 现代人群体遗传学分析
- ✅ 古代DNA联合分析 (田园洞人、福建奇岛人、绳纹人等)
- ✅ 尼安德特人/丹尼索瓦人渗入检测
- ✅ 群体混合历史建模 (qpAdm)
- ✅ 选择信号检测
- ✅ IBD/ROH亲缘关系
- ✅ GWAS关联分析
- ✅ 论文图表准备

---

## 快速开始

### 安装

1. 克隆或下载本仓库
2. 将文件复制到你的 Claude Skills 目录：
   ```bash
   mkdir -p ~/.claude/skills/population-genetics
   cp -r * ~/.claude/skills/population-genetics/
   ```

### 目录结构

```
population-genetics/
├── SKILL.md                      # 主技能文件
├── examples/
│   └── user_workflow_memory.md   # 工作流配置示例
└── references/
    ├── README.md
    ├── scripts/                  # Bash脚本模板
    │   ├── qpadm_pipeline.sh
    │   ├── archaic_seeker.sh
    │   ├── aadr_download.sh
    │   ├── admixture_batch.sh
    │   └── ibd_analysis.sh
    └── python/                    # Python可视化
        ├── pca_visualization.py
        ├── admixture_visualization.py
        ├── introgression_visualization.py
        └── f_statistics_visualization.py
```

### 使用

在 Claude 对话中，直接描述你的需求：

```
我想分析中国人群的群体结构和古代渗入情况
```

助手将自动：
1. 询问数据情况和分析目标
2. 推荐合适的方法
3. 生成可运行的脚本
4. 解读分析结果

---

## 参考模板

### 脚本模板 (references/scripts/)

| 脚本 | 用途 |
|------|------|
| qpadm_pipeline.sh | 群体混合建模 |
| archaic_seeker.sh | 古代渗入分析 |
| aadr_download.sh | Allen Lab数据获取 |
| admixture_batch.sh | Admixture批量运行 |
| ibd_analysis.sh | IBD血缘分析 |

### Python可视化 (references/python/)

| 脚本 | 用途 |
|------|------|
| pca_visualization.py | PCA散点图（支持古人投影） |
| admixture_visualization.py | 堆叠条形图 |
| introgression_visualization.py | 渗入片段染色体分布 |
| f_statistics_visualization.py | f3/f4热图 |

---

## 工作流记忆

技能会自动记住你的个性化配置：
- 集群路径
- 软件位置
- 分析参数
- 常用数据格式

你也可以直接编辑 `examples/user_workflow_memory.md` 来更新配置。

---

## 更新日志

### v2.1 (2025.03)
- 新增古代DNA分析模块
- 新增古代渗入分析模块 (ArchaicSeeker2)
- 新增群体混合历史建模 (qpAdm, Multiwave2)
- 强化软件自动检索能力
- 分离脚本模板到references目录
- 新增Python可视化模板

### v2.0 (2025.01)
- 新增自动学习用户脚本功能
- 扩展工作流记忆模块
- 新增数据获取和高级分析模块

### v1.0 (2024.01)
- 初始版本

---

## 许可证

MIT License - 欢迎自由使用和修改

---

## 贡献

欢迎提交 Issue 和 Pull Request！

如果你有更好的分析方法、脚本模板或可视化脚本，请贡献到本项目！

---

**Made with ❤️ for Population Genetics Researchers**
