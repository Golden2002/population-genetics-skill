# PCA 可视化模板 (seaborn)

**用途**: 绘制PCA散点图，支持现代人与古人样本联合投影

```python
#!/usr/bin/env python3
"""
PCA可视化 - 使用seaborn
"""
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# =====================================
# 1. 读取数据
# =====================================

# 读取PCA结果 (EIGENSOFT smartpca输出)
evec = pd.read_csv('population.evec', sep='\t', header=None,
                   names=['Sample', 'PC1', 'PC2', 'PC3', 'PC4', 'Population'])

# 读取样本信息 (可选: 添加DataType区分现代人/古人)
samples = pd.read_csv('samples_info.txt', sep='\t')

# 合并数据
df = evec.merge(samples, on='Sample', how='left')

# 区分数据来源
df['DataType'] = df['DataType'].fillna('Modern')

# =====================================
# 2. 基本PCA散点图
# =====================================

plt.figure(figsize=(10, 8))

# 配色方案
palette = sns.color_palette("tab20", n_colors=df['Population'].nunique())

sns.scatterplot(data=df, x='PC1', y='PC2', 
                hue='Population', 
                style='DataType',  # 区分古代/现代样本
                palette=palette,
                s=100, alpha=0.7,
                edgecolor='white', linewidth=0.5)

plt.xlabel('PC1', fontsize=12)
plt.ylabel('PC2', fontsize=12)
plt.title('PCA: Modern and Ancient Samples', fontsize=14)
plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left', 
           title='Population')
plt.tight_layout()
plt.savefig('pca_modern_ancient.png', dpi=300, bbox_inches='tight')
plt.show()

# =====================================
# 3. 批量PC组合
# =====================================

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

pc_pairs = [('PC1', 'PC2'), ('PC1', 'PC3'), ('PC2', 'PC3'), ('PC1', 'PC4')]

for idx, (pc_x, pc_y) in enumerate(pc_pairs):
    ax = axes[idx // 2, idx % 2]
    sns.scatterplot(data=df, x=pc_x, y=pc_y, 
                   hue='Population', palette='tab20',
                   s=60, alpha=0.7, ax=ax)
    ax.set_title(f'{pc_x} vs {pc_y}')

plt.tight_layout()
plt.savefig('pca_multi_pc.png', dpi=300)
plt.show()

# =====================================
# 4. 带置信椭圆的PCA
# =====================================

from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'

plt.figure(figsize=(12, 10))

# 按群体绘制散点 + 椭圆
for pop in df['Population'].unique():
    pop_data = df[df['Population'] == pop]
    
    # 散点
    plt.scatter(pop_data['PC1'], pop_data['PC2'], 
               label=pop, s=80, alpha=0.6)
    
    # 置信椭圆 (可选)
    # from matplotlib.patches import Ellipse
    # ellipse = Ellipse((mean_pc1, mean_pc2), width, height, 
    #                   fill=False, edgecolor='black')
    # ax.add_patch(ellipse)

plt.xlabel('PC1', fontsize=12)
plt.ylabel('PC2', fontsize=12)
plt.title('PCA with Population Ellipses')
plt.legend(bbox_to_anchor=(1.05, 1))
plt.tight_layout()
plt.savefig('pca_with_ellipses.png', dpi=300)
plt.show()
```

## 使用说明

1. **准备数据文件**:
   - `population.evec`: smartpca输出的evec文件
   - `samples_info.txt`: 样本信息表 (Sample, Population, DataType列)

2. **运行**:
   ```bash
   python pca_visualization.py
   ```

3. **输出**:
   - `pca_modern_ancient.png`: 主图
   - `pca_multi_pc.png`: 多PC组合
