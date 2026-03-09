#!/bin/bash
# =====================================
# 遗传多样性分析流程
# Author: [Your Name]
# Date: 2024-02-20
# =====================================

#SBATCH --job-name=diversity_analysis
#SBATCH --output=/PATH/TO/logs/diversity_%A_%a.out
#SBATCH --error=/PATH/TO/logs/diversity_%A_%a.err
#SBATCH --ntasks=1
#SBATCH --partition=batch
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --array=0-3  # 4个任务: ChrY, mtDNA, ChrX, Auto

# =====================================
# 严格模式
set -euo pipefail

# =====================================
# 用户配置区
# =====================================

# -------- 输入配置 --------
POP_NAME="YourPopulation"
WORK_DIR="/PATH/TO/PROJECT"

# VCF文件（按染色体类型）
VCF_Y="/PATH/TO/data/chrY.vcf.gz"
VCF_MT="/PATH/TO/data/chrM.vcf.gz"
VCF_X="/PATH/TO/data/chrX.vcf.gz"
VCF_AUTO="/PATH/TO/data/autosomes.vcf.gz"

# 样本列表
ALL_SAMPLES="${WORK_DIR}/samples/all_${POP_NAME}.txt"
MALE_SAMPLES="${WORK_DIR}/samples/male_${POP_NAME}.txt"

# -------- 分析参数 --------
WINDOW_SIZE=50000  # 窗口大小 (bp)
STEP_SIZE=25000    # 滑动步长

# -------- 目录配置 --------
PI_DIR="${WORK_DIR}/pi_window"
TAJIMA_DIR="${WORK_DIR}/tajimaD"
FST_DIR="${WORK_DIR}/fst"
SAMPLE_DIR="${WORK_DIR}/samples"
LOG_DIR="${WORK_DIR}/logs"

mkdir -p "${PI_DIR}" "${TAJIMA_DIR}" "${FST_DIR}" "${SAMPLE_DIR}" "${LOG_DIR}"

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
        echo "错误：命令 $1 未找到"
        exit 1
    fi
}

# =====================================
# 配置任务参数
# =====================================

# 数组任务配置: 0=Y, 1=mtDNA, 2=X, 3=Auto
configs=(
    "Y:${MALE_SAMPLES}:${VCF_Y}"
    "mtDNA:${ALL_SAMPLES}:${VCF_MT}"
    "X:${ALL_SAMPLES}:${VCF_X}"
    "Auto:${ALL_SAMPLES}:${VCF_AUTO}"
)

IFS=':' read -r chr_type sample_file vcf_file <<< "${configs[$SLURM_ARRAY_TASK_ID]}"

# 计算步长
step_size=$((WINDOW_SIZE / 2))

# =====================================
# 主分析流程
# =====================================

echo "=========================================="
echo "遗传多样性分析"
echo "种群: ${POP_NAME}"
echo "染色体类型: ${chr_type}"
echo "样本文件: ${sample_file}"
echo "时间: $(date)"
echo "=========================================="

# 检查依赖
check_command "vcftools"

# 检查输入文件
check_file "${vcf_file}"
check_file "${sample_file}"

# 样本数量
sample_count=$(wc -l < "${sample_file}")
echo "样本数量: ${sample_count}"

# 计算π (Nucleotide Diversity)
echo ""
echo "计算π值..."
vcftools --gzvcf "${vcf_file}" \
         --keep "${sample_file}" \
         --window-pi "${WINDOW_SIZE}" \
         --window-pi-step "${step_size}" \
         --out "${PI_DIR}/${POP_NAME}_${chr_type}_pi"

# 计算Tajima's D
echo ""
echo "计算Tajima's D..."
vcftools --gzvcf "${vcf_file}" \
         --keep "${sample_file}" \
         --TajimaD "${WINDOW_SIZE}" \
         --out "${TAJIMA_DIR}/${POP_NAME}_${chr_type}_tajimaD"

# 对于常染色体，计算Fst（如果有多个群体）
if [[ "${chr_type}" == "Auto" ]]; then
    echo ""
    echo "计算Fst（需要对比群体）..."
    # 示例：计算群体1 vs 群体2的Fst
    # vcftools --gzvcf ${vcf_file} \
    #          --weir-fst-pop pop1.txt \
    #          --weir-fst-pop pop2.txt \
    #          --out ${FST_DIR}/${POP_NAME}_fst
fi

echo ""
echo "=========================================="
echo "${chr_type} 分析完成"
echo "时间: $(date)"
echo "=========================================="
echo ""
echo "输出文件:"
echo "  π: ${PI_DIR}/${POP_NAME}_${chr_type}_pi.windowed.pi"
echo "  Tajima's D: ${TAJIMA_DIR}/${POP_NAME}_${chr_type}_tajimaD.TajimaD"
