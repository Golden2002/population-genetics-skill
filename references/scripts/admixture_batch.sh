# Admixture 批量分析脚本

**用途**: 批量运行多个K值的Admixture分析

## 完整脚本模板

```bash
#!/bin/bash
# =====================================
# Admixture 批量运行脚本
# =====================================

#SBATCH --job-name=Admixture
#SBATCH --array=1-1
#SBATCH --output=${ADMIX_DIR}/log/admixture_%A_%a.log
#SBATCH --error=${ADMIX_DIR}/log/admixture_err_%A_%a.log
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8

set -euo pipefail

# =====================================
# 配置区
# =====================================

PROJECT_ROOT="/share/home/litianxing/100My_Jino"
ADMIX_DIR="${PROJECT_ROOT}/YOUR_PROJECT/admix_results"

# 输入
INPUT_BED="${ADMIX_DIR}/input/your_data"  # 不带扩展名

# K值范围
MIN_K=2
MAX_K=8

# 运行参数
TOTAL_RUNS=1          # 总运行轮数
THREADS=8

# =====================================
# 主程序
# =====================================

current_run=$SLURM_ARRAY_TASK_ID
run_dir="${ADMIX_DIR}/run${current_run}"
mkdir -p ${run_dir}

echo "====== 开始第 ${current_run}/${TOTAL_RUNS} 轮计算 ======"
date

cd ${run_dir} || exit 1

# 运行所有K值
for K in $(seq ${MIN_K} ${MAX_K}); do
    echo "-- 计算 K=${K} --"
    
    admixture --cv ${INPUT_BED}.bed $K -j${THREADS} | tee K${K}.log
    
    # 重命名结果文件加入轮次信息
    mv ${INPUT_BED}.${K}.Q ${INPUT_BED}.run${current_run}.K${K}.Q
    mv ${INPUT_BED}.${K}.P ${INPUT_BED}.run${current_run}.K${K}.P
    
    echo "K=${K} 完成"
done

# 提取CV误差
echo "====== CV误差汇总 ======"
grep -h "CV error" K*.log | \
    sed 's/CV error (K=//g' | sed 's/):/ /g' | sort -k1 -n \
    > ${run_dir}/run${current_run}_CV.txt

cat ${run_dir}/run${current_run}_CV.txt

echo "====== 第 ${current_run} 轮完成 ======"
```

## CV误差选择最佳K值

```bash
# 提取所有运行的CV误差
cat run1/CV.txt run2/CV.txt > all_runs_CV.txt

# 绘图 (R)
cv <- read.table("all_runs_CV.txt")
plot(cv$V1, cv$V2, type="b", xlab="K", ylab="CV Error")
```

## 结果文件说明

| 文件 | 说明 |
|------|------|
| *.K*.Q | 个体祖先成分矩阵 (N样本 × K祖先) |
| *.K*.P | 等位基因频率矩阵 (K祖先 × M位点) |
| K*.log | 运行日志，含CV误差 |
| run*_CV.txt | CV误差汇总 |

## 可视化

- 参考 `../python/admixture_visualization.py`
