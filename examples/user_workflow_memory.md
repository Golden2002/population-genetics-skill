# 用户工作流配置记忆

> 本文件由 Skill 自动从用户脚本中提取生成
> 用于后续脚本编写时自动适配用户工作流

---

## 提取信息

- **提取日期**: 2024-03-09
- **来源脚本**: admixture_pipeline.sh, diversity_analysis.sh
- **提取版本**: v2.0

---

## 1. 基础配置

| 配置项 | 值 | 说明 |
|--------|-----|------|
| Shebang | `#!/bin/bash` | Bash脚本头 |
| 集群系统 | Slurm | 使用SBATCH调度 |
| 严格模式 | `set -euo pipefail` | 错误立即退出 |
| 默认线程 | 8 | `-j8` |
| 默认内存 | 32G | `--mem=32G` |
| 分区 | batch | `--partition=batch` |

### SLURM 模板

```bash
#SBATCH --job-name=JOB_NAME
#SBATCH --output=/PATH/TO/logs/%x_%A_%a.log
#SBATCH --error=/PATH/TO/logs/%x_err_%A_%a.log
#SBATCH --ntasks=1
#SBATCH --partition=batch
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1
#SBATCH --array=0-N
```

---

## 2. 目录结构

| 变量 | 路径 | 说明 |
|------|------|------|
| PROJECT_ROOT | `/PATH/TO/PROJECT` | 项目根目录 |
| PLINK_DIR | `${PROJECT_ROOT}/plink_files` | PLINK中间文件 |
| ADMIX_DIR | `${PROJECT_ROOT}/admix_results` | Admixture结果 |
| LOG_DIR | `${PROJECT_ROOT}/logs` | 日志文件 |
| SAMPLE_DIR | `${PROJECT_ROOT}/samples` | 样本列表 |
| PI_DIR | `${PROJECT_ROOT}/pi_window` | π分析结果 |
| TAJIMA_DIR | `${PROJECT_ROOT}/tajimaD` | Tajima's D结果 |
| FST_DIR | `${PROJECT_ROOT}/fst` | Fst结果 |

---

## 3. 软件配置

| 软件 | 加载方式 | 用途 |
|------|---------|------|
| PLINK | 系统命令 | 基因型数据处理 |
| admixture | 系统命令 | 群体结构分析 |
| vcftools | 系统命令 | VCF文件处理 |

---

## 4. 分析参数

### 质量控制 (QC)

| 参数 | 值 | 说明 |
|------|-----|------|
| MAF_THRESHOLD | 0.05 | 最小等位基因频率 |
| MIND_THRESHOLD | 0.1 | 个体缺失率 |
| GENO_THRESHOLD | 0.999999 | 位点缺失率 |

### LD Pruning

| 参数 | 值 | 说明 |
|------|-----|------|
| LD_WINDOW_SIZE | 50 | 窗口大小 |
| LD_WINDOW_SHIFT | 10 | 滑动步长 |
| LD_R2_THRESHOLD | 0.6 | R²阈值 |

### Admixture

| 参数 | 值 | 说明 |
|------|-----|------|
| MIN_K | 2 | 最小K值 |
| MAX_K | 20 | 最大K值 |
| ADMIX_THREADS | 8 | 线程数 |

### 遗传多样性分析

| 参数 | 值 | 说明 |
|------|-----|------|
| WINDOW_SIZE | 50000 | 窗口大小 (bp) |
| STEP_SIZE | 25000 | 滑动步长 |

---

## 5. 数据文件

### VCF文件

| 变量 | 路径示例 | 说明 |
|------|---------|------|
| VCF | `/PATH/TO/filtered.vcf.gz` | 过滤后VCF |
| VCF_Y | `/PATH/TO/data/chrY.vcf.gz` | Y染色体VCF |
| VCF_MT | `/PATH/TO/data/chrM.vcf.gz` | 线粒体VCF |
| VCF_X | `/PATH/TO/data/chrX.vcf.gz` | X染色体VCF |
| VCF_AUTO | `/PATH/TO/data/autosomes.vcf.gz` | 常染色体VCF |

### 样本列表

| 变量 | 路径示例 | 说明 |
|------|---------|------|
| ALL_SAMPLES | `${WORK_DIR}/samples/all_${POP_NAME}.txt` | 全样本列表 |
| MALE_SAMPLES | `${WORK_DIR}/samples/male_${POP_NAME}.txt` | 男性样本列表 |
| SAMPLE_LIST | `/PATH/TO/sample_lists/pop1_samples.txt` | 特定群体样本 |

### 输出文件前缀

| 变量 | 值 | 说明 |
|------|-----|------|
| OUT_PREFIX | `analysis` | 输出文件前缀 |

---

## 6. 数据格式说明

### PLINK格式
- `.bed` - 二进制基因型
- `.bim` - 位点信息
- `.fam` - 样本信息

### Admixture输出
- `.Q` - 个体祖先成分矩阵 (N × K)
- `.P` - 等位基因频率矩阵 (K × M)

### VCFtools输出
- `.windowed.pi` - π值窗口文件
- `.TajimaD` - Tajima's D值

---

## 7. 使用建议

1. **脚本生成时**：自动使用上述配置生成个性化脚本
2. **参数调整**：可在生成脚本时覆盖默认值
3. **新增分析**：可添加新的配置项到对应部分

---

*本文件由 population-genetics Skill 自动生成*
