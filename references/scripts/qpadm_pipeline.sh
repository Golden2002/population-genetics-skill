# qpAdm 群体混合建模分析脚本

**用途**: 使用qpAdm进行群体混合比例估计和混合模型检验

## 完整脚本模板

```bash
#!/bin/bash
# =====================================
# qpAdm 群体混合建模分析
# =====================================

#SBATCH --job-name=qpAdm
#SBATCH --output=${LOG_DIR}/qpadm_%j.log
#SBATCH --error=${LOG_DIR}/qpadm_err_%j.log
#SBATCH --ntasks=1
#SBATCH --partition=batch
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4

set -euo pipefail

# =====================================
# 配置区
# =====================================

PROJECT_ROOT="/share/home/litianxing/100My_Jino"
EIGENSOFT_DIR="/share/apps/gene/AdmixTools-7.0.2/bin"
CONVERTF="${EIGENSOFT_DIR}/convertf"
QPADM="${EIGENSOFT_DIR}/qpadm"

# 输入数据
DATA_DIR="${PROJECT_ROOT}/YOUR_PROJECT"
TARGET_POP="YourTarget"          # 目标人群
SOURCES_POP="Source1,Source2"  # 源人群（逗号分隔）
OUTGROUPS="Outgroup1,Outgroup2"  # 外群

# 输出目录
OUT_DIR="${DATA_DIR}/qpadm_results"
mkdir -p ${OUT_DIR}

# =====================================
# 步骤1: 准备群体列表文件
# =====================================

echo "[$(date)] 准备群体列表..."

# 目标群体 (格式: SampleID Population)
cat > ${OUT_DIR}/target.txt << 'TARGETEOF'
Sample1_Target Target
Sample2_Target Target
TARGETEOF

# 源群体
cat > ${OUT_DIR}/sources.txt << 'SOURCEEOF'
Sample1_Source1 Source1
Sample2_Source1 Source1
Sample1_Source2 Source2
Sample2_Source2 Source2
SOURCEEOF

# 外群
cat > ${OUT_DIR}/outgroups.txt << 'OUTGROUPEOF'
Sample1_Outgroup Outgroup1
Sample2_Outgroup Outgroup2
OUTGROUPEOF

# =====================================
# 步骤2: 创建parfile
# =====================================

cat > ${OUT_DIR}/left.par << 'PAREOF'
left: ${OUT_DIR}/sources.txt
right: ${OUT_DIR}/outgroups.txt
target: ${OUT_DIR}/target.txt
details: YES
allsnps: YES
PAREOF

# =====================================
# 步骤3: 运行qpAdm
# =====================================

echo "[$(date)] 运行qpAdm分析..."
${QPADM} -p ${OUT_DIR}/left.par > ${OUT_DIR}/qpadm_results.txt 2>&1

# =====================================
# 步骤4: 提取关键结果
# =====================================

echo "[$(date)] 提取结果..."
grep -A 20 "Best model:" ${OUT_DIR}/qpadm_results.txt > ${OUT_DIR}/best_model.txt
grep "p-value" ${OUT_DIR}/qpadm_results.txt > ${OUT_DIR}/pvalues.txt

echo "[$(date)] qpAdm分析完成！"
```

## 常用qpAdm模型示例

### 模型1: 简单二元混合
```
left: sources.txt (两个源群体)
right: outgroups.txt

示例: 北方汉族 = 80% 南方汉族 + 20% 古代北方人群
```

### 模型2: 多元混合
```
left: sources.txt (三个或更多源群体)
right: outgroups.txt

示例: 维吾尔族 = 40% 欧洲 + 30% 东亚 + 30% 中亚
```

## 结果解读

- **Best model**: p-value > 0.05 表示模型可接受
- **mixing proportions**: 各源群体的比例估计值
- **rank**: 模型自由度

## 相关文件

- 需配合EIGENSTRAT格式数据使用
- 参考: `convertf` 用于格式转换
