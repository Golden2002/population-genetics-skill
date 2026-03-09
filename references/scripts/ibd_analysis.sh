# IBD 血缘关系分析脚本

**用途**: 使用Refined IBD进行血缘片段检测

## 完整脚本模板

```bash
#!/bin/bash
# =====================================
# Refined IBD 血缘分析
# =====================================

#SBATCH --job-name=IBD
#SBATCH --output=${LOG_DIR}/IBD_%j.log
#SBATCH --error=${LOG_DIR}/IBD_err_%j.log
#SBATCH --ntasks=1
#SBATCH --partition=batch
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8

set -euo pipefail

# =====================================
# 配置区
# =====================================

PROJECT_ROOT="/share/home/litianxing/100My_Jino"
REFINED_IBD="${PROJECT_ROOT}/107.IBD/refined-ibd.17Jan20.102.jar"
MERGE_IBD_SEG="${PROJECT_ROOT}/107.IBD/merge-ibd-segments.17Jan20.102.jar"

# 输入
VCF="/share/home/litianxing/100My_Jino/YOUR_DATA/NGS.phased.vcf.gz"
ID_LIST="/share/home/litianxing/100My_Jino/YOUR_DATA/poplist/YourPop.list"

# 染色体VCF目录
VCF_CHR_DIR="${PROJECT_ROOT}/YOUR_PROJECT/data/chrvcf"
MAP_DIR="${PROJECT_ROOT}/YOUR_PROJECT/map"

# 输出
OUTDIR="${PROJECT_ROOT}/YOUR_PROJECT/results/YourPop"
mkdir -p ${OUTDIR}/refined

# Java
JAVA="/share/apps/cluster/jdk-17.0.5/bin/java"

# =====================================
# 步骤1: 提取个体子集VCF
# =====================================

echo "[$(date)] 提取个体子集VCF..."

SUBSET_VCF="${VCF_CHR_DIR}/YourPop.subset.vcf.gz"
bcftools view -S ${ID_LIST} --force-samples -Oz -o ${SUBSET_VCF} ${VCF}
bcftools index ${SUBSET_VCF}

echo "[$(date)] 子集VCF提取完成"

# =====================================
# 步骤2: 逐染色体分析
# =====================================

for chr in {1..22}; do
    echo "▶ 处理染色体 $chr"
    
    # 拆分染色体
    CHR_VCF="${VCF_CHR_DIR}/chr${chr}.vcf.gz"
    bcftools view -r chr${chr} -Oz -o ${CHR_VCF} ${SUBSET_VCF}
    bcftools index ${CHR_VCF}
    
    MAP_FILE="${MAP_DIR}/plink.chr${chr}.GRCh38.map"
    
    # Refined IBD分析
    echo "  ⏳ Refined IBD chr${chr}"
    $JAVA -Xmx30g -jar ${REFINED_IBD} \
        gt=${CHR_VCF} \
        map=${MAP_FILE} \
        out=${OUTDIR}/refined/chr${chr}.refined \
        nthreads=8 \
        length=1.0 \
        lod=3.0
    
    # 合并片段
    echo "  ⏳ 合并片段 chr${chr}"
    zcat ${OUTDIR}/refined/chr${chr}.refined.ibd.gz | \
    $JAVA -jar ${MERGE_IBD_SEG} \
        ${CHR_VCF} \
        ${MAP_FILE} \
        0.6 \
        1 | bgzip -c > ${OUTDIR}/refined/chr${chr}.refined.merged.ibd.gz
    
    echo "✅ 染色体 $chr 完成"
done

# =====================================
# 步骤3: 合并所有染色体结果
# =====================================

echo "[$(date)] 合并所有染色体结果..."

zcat ${OUTDIR}/refined/chr*.refined.merged.ibd.gz > \
    ${OUTDIR}/YourPop.refined.allchr.merged.ibd.txt

echo "[$(date)] IBD分析完成！"
```

## 关键参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| -Xmx | 30g | Java堆内存 |
| length | 1.0 | 最小IBD片段长度(cM) |
| lod | 3.0 | LOD评分阈值 |

## 结果文件

| 文件 | 说明 |
|------|------|
| *.ibd.gz | 原始IBD片段 |
| *.merged.ibd.gz | 合并后IBD片段 |
| *.allchr.merged.ibd.txt | 所有染色体合并 |

## 相关工具

- Refined IBD: https://faculty.washington.edu/wtaye/IBD.php
- Hap-IBD: https://github.com/zhangfw9527/Hap-IBD
