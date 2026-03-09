# ArchaicSeeker2 古代渗入分析脚本

**用途**: 检测现代人基因组中的尼安德特人和丹尼索瓦人渗入片段

## 完整脚本模板

```bash
#!/bin/bash
# =====================================
# ArchaicSeeker2 古代渗入分析
# =====================================

#SBATCH --job-name=ArchaicSeeker
#SBATCH --output=${LOG_DIR}/archaic_%j.log
#SBATCH --error=${LOG_DIR}/archaic_err_%j.log
#SBATCH --ntasks=1
#SBATCH --partition=batch
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8

set -euo pipefail

# =====================================
# 配置区
# =====================================

PROJECT_ROOT="/share/home/litianxing/100My_Jino"
ARCHAIC_DIR="${PROJECT_ROOT}/ArchaicSeeker2"

# 输入数据
INPUT_VCF="${PROJECT_ROOT}/YOUR_DATA/phased.vcf.gz"
SAMPLE_LIST="${PROJECT_ROOT}/YOUR_DATA/modern_samples.txt"

# 参考古代样本
NEANDERTHAL_VCF="${ARCHAIC_DIR}/reference/Altai_Vindija29_whole.vcf.gz"
DENISOVAN_VCF="${ARCHAIC_DIR}/reference/Denisova11_whole.vcf.gz"
ANCESTRAL_ALLELES="${ARCHAIC_DIR}/reference/ancestral_alleles.txt"

# 输出
OUT_DIR="${PROJECT_ROOT}/YOUR_PROJECT/archaic_results"
mkdir -p ${OUT_DIR}

# 参数
MIN_LENGTH=5000       # 最小渗入片段长度(bp)
MIN_SNP=50            # 最小SNP数
THREADS=8

# =====================================
# 步骤1: 检查数据格式
# =====================================

echo "[$(date)] 检查输入数据格式..."

# 需要 .haps 和 .sample 格式（ShapeIt4输出）
# 如需转换:
# plink2 --vcf input.vcf.gz --haps output --sample output

# =====================================
# 步骤2: 运行ArchaicSeeker2
# =====================================

echo "[$(date)] 运行ArchaicSeeker2..."

python ${ARCHAIC_DIR}/ArchaicSeeker2.py \
    -vcf ${INPUT_VCF} \
    -s ${SAMPLE_LIST} \
    -o ${OUT_DIR}/archaic \
    -anc ${ANCESTRAL_ALLELES} \
    -minLen ${MIN_LENGTH} \
    -minSNP ${MIN_SNP} \
    -t ${THREADS} \
    --ref_vcf ${NEANDERTHAL_VCF} \
    --denisovan_vcf ${DENISOVAN_VCF}

# =====================================
# 步骤3: 结果解读
# =====================================

echo "[$(date)] 分析完成！"

# 关键输出文件:
# ${OUT_DIR}/archaic.archaic - 渗入片段列表
# ${OUT_DIR}/archaic.archaic_anc - 祖先来源估计
# ${OUT_DIR}/archaic.archaic_mod - 现代人渗入部分

# 计算渗入比例:
echo "=== 渗入统计 ==="
echo "尼安德特人渗入片段数:"
grep -c "NEANDER" ${OUT_DIR}/archaic.archaic || echo "0"

echo "丹尼索瓦人渗入片段数:"
grep -c "DENISOVAN" ${OUT_DIR}/archaic.archaic || echo "0"

# 计算总长度
echo "尼安德特人总渗入长度:"
awk '/NEANDER/ {sum+=$3-$2} END {print sum}' ${OUT_DIR}/archaic.archaic

echo "丹尼索瓦人总渗入长度:"
awk '/DENISOVAN/ {sum+=$3-$2} END {print sum}' ${OUT_DIR}/archaic.archaic
```

## 关键参数说明

| 参数 | 默认值 | 说明 |
|------|--------|------|
| -minLen | 5000 | 最小渗入片段长度(bp) |
| -minSNP | 50 | 最小SNP数 |
| -t | 8 | 线程数 |

## 渗入比例参考

| 人群 | 尼安德特人 | 丹尼索瓦人 |
|------|-----------|-----------|
| 欧洲人 | 2-4% | ~0.2% |
| 东亚人 | 2-3% | 0.2-0.5% |
| 藏族 | 2.4% | 0.3-0.5% |
| 澳大利亚原住民 | 2-3% | 4-6% |

## 相关文件

- 需要ShapeIt4分型后的 .haps/.sample 文件
- 需要古代参考基因组 VCF (尼安德特人/丹尼索瓦人)
- 需要祖先等位基因文件
