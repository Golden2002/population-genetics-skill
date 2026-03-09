#!/bin/bash
# =====================================
# Admixture 群体结构分析流程
# Author: [Your Name]
# Date: 2024-01-15
# =====================================

#SBATCH --job-name=Admixture_Analysis
#SBATCH --output=/PATH/TO/logs/admixture_%A_%a.log
#SBATCH --error=/PATH/TO/logs/admixture_err_%A_%a.log
#SBATCH --ntasks=1
#SBATCH --partition=batch
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --nodes=1

# =====================================
# 严格模式
set -euo pipefail

# =====================================
# 用户配置区
# =====================================

# -------- 输入配置 --------
VCF="/PATH/TO/filtered.vcf.gz"
SAMPLE_LIST="/PATH/TO/sample_lists/pop1_samples.txt"  # 可选
OUT_PREFIX="analysis"

# -------- 分析参数 --------
MAF_THRESHOLD=0.05
MIND_THRESHOLD=0.1
GENO_THRESHOLD=0.999999
LD_WINDOW_SIZE=50
LD_WINDOW_SHIFT=10
LD_R2_THRESHOLD=0.6

MIN_K=2
MAX_K=20
ADMIX_THREADS=8

# -------- 目录配置 --------
PROJECT_ROOT="/PATH/TO/PROJECT"
PLINK_DIR="${PROJECT_ROOT}/plink_files"
ADMIX_DIR="${PROJECT_ROOT}/admix_results"
LOG_DIR="${PROJECT_ROOT}/logs"

mkdir -p "${PLINK_DIR}" "${ADMIX_DIR}" "${LOG_DIR}"

# =====================================
# 预检查函数
# =====================================

check_file() {
    if [[ ! -f "$1" ]]; then
        echo "错误：文件不存在: $1"
        exit 1
    fi
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "错误：命令 $1 未找到，请确保已加载相应模块"
        exit 1
    fi
}

# =====================================
# 主分析流程
# =====================================

echo "=========================================="
echo "Admixture分析开始"
echo "时间: $(date)"
echo "=========================================="

# 检查依赖
check_command "plink"
check_command "admixture"

# Step 1: VCF转PLINK格式
echo "Step 1: VCF转PLINK格式..."
RAW_PLINK="${PLINK_DIR}/${OUT_PREFIX}.raw"

plink --vcf "${VCF}" \
      --make-bed \
      --out "${RAW_PLINK}" \
      --allow-extra-chr \
      --double-id \
      --vcf-half-call missing 2>&1 | tee "${LOG_DIR}/plink_convert.log"

# Step 2: 质量控制
echo "Step 2: 质量控制..."
FILTERED_PLINK="${PLINK_DIR}/${OUT_PREFIX}.maf_filtered"

plink --bfile "${RAW_PLINK}" \
      --make-bed \
      --out "${FILTERED_PLINK}" \
      --mind ${MIND_THRESHOLD} \
      --maf ${MAF_THRESHOLD} \
      --geno ${GENO_THRESHOLD} \
      --allow-extra-chr 2>&1 | tee "${LOG_DIR}/plink_qc.log"

# Step 3: LD Pruning
echo "Step 3: LD Pruning..."
PRUNING_OUTPUT="${ADMIX_DIR}/pruning"

plink --bfile "${FILTERED_PLINK}" \
      --indep-pairwise ${LD_WINDOW_SIZE} ${LD_WINDOW_SHIFT} ${LD_R2_THRESHOLD} \
      --out "${PRUNING_OUTPUT}" \
      --allow-extra-chr 2>&1 | tee "${LOG_DIR}/ld_pruning.log"

# Step 4: 生成Admixture输入
echo "Step 4: 生成Admixture输入文件..."
ADMIX_INPUT="${ADMIX_DIR}/${OUT_PREFIX}_pruned"

plink --bfile "${FILTERED_PLINK}" \
      --extract "${PRUNING_OUTPUT}.prune.in" \
      --make-bed \
      --out "${ADMIX_INPUT}" \
      --allow-extra-chr

# Step 5: 运行Admixture
echo "Step 5: 运行Admixture分析 (K=${MIN_K}到${MAX_K})..."

for K in $(seq ${MIN_K} ${MAX_K}); do
    echo "  计算 K=${K}..."
    admixture --cv "${ADMIX_INPUT}.bed" ${K} -j${ADMIX_THREADS} 2>&1 | tee "K${K}.log"
done

# Step 6: 提取CV误差
echo "Step 6: 提取CV误差..."
grep -h "CV error" K*.log | \
    sed 's/CV error (K=//g' | \
    sed 's/):/ /g' | \
    sort -k1 -n > CV_errors.txt

echo ""
echo "=========================================="
echo "CV误差汇总:"
echo "=========================================="
cat CV_errors.txt

echo ""
echo "分析完成! 时间: $(date)"
echo "建议使用CV误差最小的K值"
