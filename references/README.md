# 参考文件目录

本目录包含群体遗传学分析的代码模板和可视化脚本。

## 目录结构

```
references/
├── scripts/          # Bash脚本模板
│   ├── qpadm_pipeline.sh
│   ├── archaic_seeker.sh
│   ├── aadr_download.sh
│   ├── admixture_batch.sh
│   └── ibd_analysis.sh
│
├── python/           # Python可视化模板
│   ├── pca_visualization.py
│   ├── admixture_visualization.py
│   ├── introgression_visualization.py
│   └── f_statistics_visualization.py
│
└── examples/         # 示例文件 (见上层目录)
    └── user_workflow_memory.md
```

## 快速索引

### Bash脚本模板

| 脚本 | 用途 |
|------|------|
| qpadm_pipeline.sh | 群体混合建模 (qpAdm) |
| archaic_seeker.sh | 古代渗入分析 (ArchaicSeeker2) |
| aadr_download.sh | Allen Lab古DNA数据获取 |
| admixture_batch.sh | Admixture批量运行 |
| ibd_analysis.sh | IBD血缘片段分析 |

### Python可视化

| 脚本 | 用途 |
|------|------|
| pca_visualization.py | PCA散点图 |
| admixture_visualization.py | Admixture堆叠条形图 |
| introgression_visualization.py | 渗入片段分布图 |
| f_statistics_visualization.py | f3/f4热图 |

## 使用方法

1. **复制模板**: 将需要的模板复制到你的项目目录
2. **修改配置**: 根据你的数据路径修改配置区参数
3. **运行**: 提交到集群或本地运行

## 相关文档

- SKILL.md: 完整的技能说明
- examples/user_workflow_memory.md: 工作流记忆示例
