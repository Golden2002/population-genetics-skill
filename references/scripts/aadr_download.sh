# Allen Lab AADR 古DNA数据获取脚本

**用途**: 从Allen Ancient DNA Resource获取古DNA数据

## 数据申请

1. 访问: https://reich.hms.harvard.edu/allen-ancient-dna-resource
2. 填写申请表格
3. 获批后获取FTP下载链接

## 完整脚本模板

```bash
#!/bin/bash
# =====================================
# Allen Lab 古DNA数据获取
# =====================================

# 配置
AADR_VERSION="v54.1"  # 检查最新版本
DOWNLOAD_DIR="/share/home/litianxing/100My_Jino/AADR"
mkdir -p ${DOWNLOAD_DIR}

# FTP链接 (获批后获取)
AADR_FTP_LINK="ftp://ftp.reich_data_..."

# =====================================
# 方法1: wget 下载
# =====================================

echo "[$(date)] 使用wget下载AADR ${AADR_VERSION}..."

wget -r -np -nhtl 5 \
    --accept "*.bed,*.bim,*.fam,*.ind,*.snp,*.geno" \
    -P ${DOWNLOAD_DIR} \
    ${AADR_FTP_LINK}

# =====================================
# 方法2: aria2c (更快)
# =====================================

# aria2c -s 10 -x 10 -d ${DOWNLOAD_DIR} \
#     ${AADR_FTP_LINK}/*.1240k.*

# =====================================
# 转换为EIGENSTRAT格式
# =====================================

echo "[$(date)] 转换为EIGENSTRAT格式..."

CONVERTF="/share/apps/gene/AdmixTools-7.0.2/bin/convertf"

# 1240k数据转换
cat > ${DOWNLOAD_DIR}/parfile_1240k << 'PAREOF'
genotypename:    ${DOWNLOAD_DIR}/1240k.bed
snpname:         ${DOWNLOAD_DIR}/1240k.bim
indivname:       ${DOWNLOAD_DIR}/1240k.fam
outputformat:    EIGENSTRAT
genotypeoutname: ${DOWNLOAD_DIR}/1240k.geno
snpoutname:      ${DOWNLOAD_DIR}/1240k.snp
indivoutname:    ${DOWNLOAD_DIR}/1240k.ind
PAREOF

${CONVERTF} -p ${DOWNLOAD_DIR}/parfile_1240k

# HO数据转换
cat > ${DOWNLOAD_DIR}/parfile_ho << 'PAREOF'
genotypename:    ${DOWNLOAD_DIR}/HO.bed
snpname:         ${DOWNLOAD_DIR}/HO.bim
indivname:       ${DOWNLOAD_DIR}/HO.fam
outputformat:    EIGENSTRAT
genotypeoutname: ${DOWNLOAD_DIR}/HO.geno
snpoutname:      ${DOWNLOAD_DIR}/HO.snp
indivoutname:    ${DOWNLOAD_DIR}/HO.ind
PAREOF

${CONVERTF} -p ${DOWNLOAD_DIR}/parfile_ho

echo "[$(date)] 数据准备完成！"
echo "1240k: ${DOWNLOAD_DIR}/1240k.geno/.snp/.ind"
echo "HO: ${DOWNLOAD_DIR}/HO.geno/.snp/.ind"
```

## 常用数据集

| 数据集 | 位点数 | 说明 |
|--------|--------|------|
| 1240k | ~1.2M | 目标序列捕获位点，覆盖广泛 |
| HO | ~600k | HumanOrigins阵列 |
| Y-chr | ~100k | Y染色体位点 |
| mitogenome | ~1.6k | 线粒体基因组 |

## 使用建议

1. **1240k**: 适合大多数分析，与大多数已发表数据可比较
2. **HO**: 适合需要与公开数据集合并的分析

## 相关文件

- 参考convertf文档进行格式转换
- 配合qpAdm等ADMIXTOOLS使用
