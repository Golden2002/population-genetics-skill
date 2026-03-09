# Admixture 堆叠条形图可视化

**用途**: 绘制Admixture祖先成分堆叠条形图

```python
#!/usr/bin/env python3
"""
Admixture可视化 - 堆叠条形图
"""
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import glob
import os

# =====================================
# 1. 读取Q矩阵
# =====================================

def load_q_matrix(q_file):
    """读取单个Q文件"""
    with open(q_file, 'r') as f:
        lines = f.readlines()
    
    # Q矩阵: 每行一个个体, 每列一个K值
    data = []
    for line in lines:
        vals = [float(x) for x in line.strip().split()]
        data.append(vals)
    
    return pd.DataFrame(data)

def load_all_q_files(q_prefix, K_range):
    """加载所有K值的Q矩阵"""
    all_q = {}
    for k in K_range:
        q_file = f"{q_prefix}.{k}.Q"
        if os.path.exists(q_file):
            all_q[k] = load_q_matrix(q_file)
    return all_q

# =====================================
# 2. 读取样本顺序
# =====================================

# 如果有样本顺序文件
sample_order = []
with open('sample_order.txt', 'r') as f:
    for line in f:
        sample_order.append(line.strip())

# =====================================
# 3. 单K值可视化
# =====================================

def plot_single_k(q_df, k, sample_order=None, output_prefix='admixture'):
    """绘制单个K值的堆叠条形图"""
    
    fig, ax = plt.subplots(figsize=(max(12, len(q_df) * 0.3), 6))
    
    # 设置颜色
    colors = sns.color_palette("Set3", n_colors=k)
    
    # 准备数据
    plot_data = q_df.values.T  # 转置: K x N
    if sample_order:
        x_labels = sample_order
    else:
        x_labels = [f'S{i+1}' for i in range(len(q_df))]
    
    # 绘制堆叠条形图
    bottom = np.zeros(len(q_df))
    for i in range(k):
        ax.bar(range(len(q_df)), plot_data[i], bottom=bottom, 
               color=colors[i], label=f'K{i+1}', width=0.8)
        bottom += plot_data[i]
    
    ax.set_xticks(range(len(q_df)))
    ax.set_xticklabels(x_labels, rotation=90, fontsize=6)
    ax.set_ylabel('Ancestry Proportion', fontsize=12)
    ax.set_xlabel('Individuals', fontsize=12)
    ax.set_title(f'Admixture K={k}', fontsize=14)
    ax.set_ylim(0, 1)
    
    # 只有K值较小时显示图例
    if k <= 6:
        ax.legend(bbox_to_anchor=(1.02, 1), loc='upper left')
    
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_K{k}.png', dpi=300, bbox_inches='tight')
    plt.close()

# =====================================
# 4. 多K值并排显示
# =====================================

def plot_multiple_k(all_q, k_values, sample_order=None, output_prefix='admixture'):
    """绘制多个K值的堆叠条形图"""
    
    n_k = len(k_values)
    fig, axes = plt.subplots(n_k, 1, figsize=(max(14, sum([len(all_q[k]) for k in k_values]) * 0.1), 4*n_k))
    
    if n_k == 1:
        axes = [axes]
    
    for idx, k in enumerate(k_values):
        ax = axes[idx]
        q_df = all_q[k]
        colors = sns.color_palette("Set3", n_colors=k)
        
        plot_data = q_df.values.T
        if sample_order:
            x_labels = sample_order
        else:
            x_labels = [f'S{i+1}' for i in range(len(q_df))]
        
        bottom = np.zeros(len(q_df))
        for i in range(k):
            ax.bar(range(len(q_df)), plot_data[i], bottom=bottom, 
                   color=colors[i], width=0.8)
            bottom += plot_data[i]
        
        ax.set_xticks(range(len(q_df)))
        ax.set_xticklabels(x_labels, rotation=90, fontsize=4)
        ax.set_ylabel('Proportion')
        ax.set_title(f'K={k}')
        ax.set_ylim(0, 1)
    
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_all_K.png', dpi=300, bbox_inches='tight')
    plt.close()

# =====================================
# 5. CV误差图
# =====================================

def plot_cv_error(cv_file, output_prefix='admixture'):
    """绘制CV误差曲线"""
    
    cv_data = []
    with open(cv_file, 'r') as f:
        for line in f:
            parts = line.strip().replace(':', '').split()
            if len(parts) >= 2:
                k = int(parts[0].replace('K', ''))
                cv = float(parts[1])
                cv_data.append({'K': k, 'CV': cv})
    
    cv_df = pd.DataFrame(cv_data)
    
    plt.figure(figsize=(8, 5))
    plt.plot(cv_df['K'], cv_df['CV'], 'o-', markersize=8)
    plt.xlabel('K', fontsize=12)
    plt.ylabel('Cross-validation Error', fontsize=12)
    plt.title('Admixture CV Error')
    plt.xticks(cv_df['K'])
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f'{output_prefix}_cv_error.png', dpi=300)
    plt.close()

# =====================================
# 主程序
# =====================================

if __name__ == '__main__':
    # 配置
    Q_PREFIX = 'your_data'  # Q文件前缀
    K_RANGE = range(2, 9)   # K值范围
    
    # 加载数据
    all_q = load_all_q_files(Q_PREFIX, K_RANGE)
    
    # 读取样本顺序
    sample_order = []
    if os.path.exists('sample_order.txt'):
        with open('sample_order.txt', 'r') as f:
            sample_order = [line.strip() for line in f]
    
    # 绘制单个K值
    for k in K_RANGE:
        if k in all_q:
            plot_single_k(all_q[k], k, sample_order, Q_PREFIX)
    
    # 绘制多K值
    plot_multiple_k(all_q, list(K_RANGE), sample_order, Q_PREFIX)
    
    # 绘制CV误差
    if os.path.exists(f'{Q_PREFIX}_CV.txt'):
        plot_cv_error(f'{Q_PREFIX}_CV.txt', Q_PREFIX)
    
    print("可视化完成!")
```

## 使用说明

1. **准备数据**:
   - `your_data.2.Q`, `your_data.3.Q`, ... : Admixture输出的Q文件
   - `sample_order.txt` : 样本顺序（可选，每行一个样本ID）

2. **运行**:
   ```bash
   python admixture_visualization.py
   ```

3. **输出**:
   - `your_data_K2.png`, `your_data_K3.png`, ... : 各K值单独图
   - `your_data_all_K.png` : 所有K值并排
   - `your_data_cv_error.png` : CV误差曲线
