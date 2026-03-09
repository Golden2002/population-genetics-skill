# f3/f4-statistics 热图可视化

**用途**: 绘制f-statistics结果的热图

```python
#!/usr/bin/env python3
"""
f3/f4-statistics 热图可视化
"""
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import os

# =====================================
# 1. 读取f4结果
# =====================================

# f4结果格式示例:
# Pop1    Pop2    Pop3    Pop4    f4      Z
# Yoruba  French  Han     Japanese 0.012  5.2

def load_f4_results(f4_file):
    """读取f4结果文件"""
    df = pd.read_csv(f4_file, sep='\t')
    return df

def load_f3_results(f3_file):
    """读取f3结果文件"""
    df = pd.read_csv(f3_file, sep='\t')
    return df

# =====================================
# 2. 转换为热图矩阵
# =====================================

def f4_to_matrix(f4_df, value_col='f4', pop1_col='Pop1', pop2_col='Pop2'):
    """将f4结果转换为热图矩阵"""
    
    # 创建群体列表
    pops = sorted(set(f4_df[pop1_col].unique()) | set(f4_df[pop2_col].unique()))
    n = len(pops)
    
    # 创建矩阵
    matrix = np.zeros((n, n))
    
    # 填充矩阵
    for _, row in f4_df.iterrows():
        p1, p2 = row[pop1_col], row[pop2_col]
        i = pops.index(p1)
        j = pops.index(p2)
        matrix[i, j] = row[value_col]
        matrix[j, i] = row[value_col]  # 对称
    
    return pd.DataFrame(matrix, index=pops, columns=pops)

def zscore_to_matrix(f4_df, z_col='Z', pop1_col='Pop1', pop2_col='Pop2'):
    """将Z-score转换为热图矩阵"""
    
    pops = sorted(set(f4_df[pop1_col].unique()) | set(f4_df[pop2_col].unique()))
    n = len(pops)
    
    matrix = np.zeros((n, n))
    
    for _, row in f4_df.iterrows():
        p1, p2 = row[pop1_col], row[pop2_col]
        i = pops.index(p1)
        j = pops.index(p2)
        matrix[i, j] = row[z_col]
        matrix[j, i] = -row[z_col]  # 反对称
    
    return pd.DataFrame(matrix, index=pops, columns=pops)

# =====================================
# 3. 绘制f4热图
# =====================================

def plot_f4_heatmap(f4_file, output_prefix='f4'):
    """绘制f4热图"""
    
    # 读取数据
    f4_df = load_f4_results(f4_file)
    
    # 转换为矩阵
    f4_matrix = f4_to_matrix(f4_df, 'f4')
    z_matrix = zscore_to_matrix(f4_df, 'Z')
    
    # 创建图形
    fig, axes = plt.subplots(1, 2, figsize=(18, 8))
    
    # f4值热图
    sns.heatmap(f4_matrix, annot=True, fmt='.4f', 
                cmap='RdBu_r', center=0,
                linewidths=0.5, ax=axes[0],
                cbar_kws={'label': 'f4'})
    axes[0].set_title('f4-statistics: (A, B; C, D)', fontsize=14)
    axes[0].set_xlabel('Population')
    axes[0].set_ylabel('Population')
    
    # Z-score热图
    sns.heatmap(z_matrix, annot=True, fmt='.1f', 
                cmap='RdBu_r', center=0,
                linewidths=0.5, ax=axes[1],
                vmin=-10, vmax=10,
                cbar_kws={'label': 'Z-score'})
    axes[1].set_title('f4 Z-scores', fontsize=14)
    axes[1].set_xlabel('Population')
    axes[1].set_ylabel('Population')
    
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_heatmap.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    return f4_matrix, z_matrix

# =====================================
# 4. 绘制f3热图
# =====================================

def plot_f3_heatmap(f3_file, output_prefix='f3'):
    """绘制f3热图 (混合检测)"""
    
    f3_df = load_f3_results(f3_file)
    
    # f3 = (A; B, C) 格式
    # 转换为矩阵: 行=A, 列=(B,C组合)
    
    pops = sorted(f3_df['A'].unique())
    
    # 取每个群体最佳的f3值
    f3_matrix = pd.DataFrame(index=pops, columns=pops, dtype=float)
    
    for _, row in f3_df.iterrows():
        a = row['A']
        b = row['B']
        c = row['C']
        
        # f3(A; B, C)
        key1 = f"{b}_{c}"
        key2 = f"{c}_{b}"
        
        if a in f3_matrix.index:
            f3_matrix.loc[a, b] = row['f3']
    
    # 绘图
    plt.figure(figsize=(12, 10))
    sns.heatmap(f3_matrix.astype(float), annot=True, fmt='.4f',
                cmap='YlOrRd', linewidths=0.5,
                cbar_kws={'label': 'f3'})
    plt.title('f3-statistics: f3(A; B, C)', fontsize=14)
    plt.xlabel('Population')
    plt.ylabel('Target Population (A)')
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_heatmap.png', dpi=300)
    plt.show()
    
    return f3_matrix

# =====================================
# 5. 显著性标记
# =====================================

def plot_f4_with_significance(f4_df, output_prefix='f4'):
    """绘制带显著性标记的f4热图"""
    
    f4_matrix = f4_to_matrix(f4_df, 'f4')
    z_matrix = zscore_to_matrix(f4_df, 'Z')
    
    # 创建标记矩阵
    sig_matrix = z_matrix.copy()
    sig_matrix = sig_matrix.applymap(
        lambda x: '***' if abs(x) > 3 else ('**' if abs(x) > 2 else ('*' if abs(x) > 1.5 else ''))
    )
    
    # 绘图
    fig, ax = plt.subplots(figsize=(14, 12))
    
    # 热图
    sns.heatmap(f4_matrix, annot=sig_matrix, fmt='',
                cmap='RdBu_r', center=0,
                linewidths=0.5, ax=ax,
                cbar_kws={'label': 'f4'},
                annot_kws={'fontsize': 8})
    
    ax.set_title('f4-statistics with Significance\n(*** p<0.001, ** p<0.01, * p<0.05)', 
                fontsize=14)
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_sig.png', dpi=300)
    plt.show()

# =====================================
# 主程序
# =====================================

if __name__ == '__main__':
    # 配置
    F4_FILE = 'f4_results.txt'
    F3_FILE = 'f3_results.txt'
    
    if os.path.exists(F4_FILE):
        print("绘制f4热图...")
        plot_f4_heatmap(F4_FILE)
        plot_f4_with_significance(F4_FILE)
    
    if os.path.exists(F3_FILE):
        print("绘制f3热图...")
        plot_f3_heatmap(F3_FILE)
    
    print("完成!")
```

## 使用说明

1. **准备数据**:
   - `f4_results.txt`: qp4Pop输出的f4结果
   - `f3_results.txt`: qp3Pop输出的f3结果

2. **格式**:
   ```
   Pop1    Pop2    Pop3    Pop4    f4      Z
   Yoruba  French  Han     Japanese 0.012  5.2
   ```

3. **运行**:
   ```bash
   python f_statistics_visualization.py
   ```

4. **输出**:
   - `f4_heatmap.png`: f4值+Z-score热图
   - `f4_sig.png`: 带显著性标记
   - `f3_heatmap.png`: f3混合检测热图
