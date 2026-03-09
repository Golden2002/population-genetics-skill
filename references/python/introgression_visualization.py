# 古代渗入片段可视化

**用途**: 绘制尼安德特人/丹尼索瓦人渗入片段的染色体分布

```python
#!/usr/bin/env python3
"""
古代渗入片段可视化 - Manhattan-style plot
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# =====================================
# 1. 读取渗入片段数据
# =====================================

# 读取ArchaicSeeker输出
archaic = pd.read_csv('sample.archaic', sep='\t')

# 查看列名
print("列名:", archaic.columns.tolist())

# 关键列:
# CHROM, POS_START, POS_END, LENGTH
# NEANDER (0/1), DENISOVAN (0/1)

# =====================================
# 2. 按染色体统计
# =====================================

def get_chr_stats(archaic_df):
    """按染色体统计渗入"""
    
    stats = []
    for chrom in range(1, 23):
        chr_data = archaic_df[archaic_df['CHROM'] == chrom]
        
        if len(chr_data) == 0:
            stats.append({
                'Chr': chrom,
                'N_Fragments': 0,
                'Total_Length': 0,
                'Neander_Fragments': 0,
                'Denisovan_Fragments': 0,
                'Neander_Length': 0,
                'Denisovan_Length': 0
            })
            continue
        
        # 总计
        total_length = (chr_data['POS_END'] - chr_data['POS_START']).sum()
        n_frag = len(chr_data)
        
        # 尼安德特人
        neander = chr_data[chr_data.get('NEANDER', 0) == 1] if 'NEANDER' in chr_data.columns else pd.DataFrame()
        neander_len = (neander['POS_END'] - neander['POS_START']).sum() if len(neander) > 0 else 0
        
        # 丹尼索瓦人
        denisovan = chr_data[chr_data.get('DENISOVAN', 0) == 1] if 'DENISOVAN' in chr_data.columns else pd.DataFrame()
        denisovan_len = (denisovan['POS_END'] - denisovan['POS_START']).sum() if len(denisovan) > 0 else 0
        
        stats.append({
            'Chr': chrom,
            'N_Fragments': n_frag,
            'Total_Length': total_length,
            'Neander_Fragments': len(neander),
            'Denisovan_Fragments': len(denisovan),
            'Neander_Length': neander_len,
            'Denisovan_Length': denisovan_len
        })
    
    return pd.DataFrame(stats)

chr_stats = get_chr_stats(archaic)

# =====================================
# 3. 绘制染色体分布图
# =====================================

fig, axes = plt.subplots(3, 1, 12))

# figsize=(14, 总片段数
axes[0].bar(chr_stats['Chr'], chr_stats['N_Fragments'], 
            color='steelblue', edgecolor='white')
axes[0].set_ylabel('Number of Fragments')
axes[0].set_title('Archaic Introgression by Chromosome', fontsize=14)
axes[0].set_xticks(range(1, 23))

# 尼安德特人
axes[1].bar(chr_stats['Chr'], chr_stats['Neander_Length'] / 1e6, 
            color='darkorange', edgecolor='white')
axes[1].set_ylabel('Total Length (Mb)')
axes[1].set_title('Neanderthal Introgression')
axes[1].set_xticks(range(1, 23))

# 丹尼索瓦人
axes[2].bar(chr_stats['Chr'], chr_stats['Denisovan_Length'] / 1e6, 
            color='darkgreen', edgecolor='white')
axes[2].set_ylabel('Total Length (Mb)')
axes[2].set_title('Denisovan Introgression')
axes[2].set_xlabel('Chromosome')
axes[2].set_xticks(range(1, 23))

plt.tight_layout()
plt.savefig('introgression_by_chr.png', dpi=300)
plt.show()

# =====================================
# 4. Manhattan-style plot
# =====================================

def plot_manhattan(archaic_df, chrom_col='CHROM', pos_col='POS', 
                   stat_col=None, title='Manhattan Plot'):
    """绘制Manhattan-style图"""
    
    # 准备数据
    plot_data = archaic_df.copy()
    plot_data['chrom_pos'] = plot_data.apply(
        lambda x: x[chrom_col] * 1e9 + x[pos_col], axis=1)
    
    # 染色体颜色
    colors = ['#1f77b4', '#ff7f0e'] * 12
    
    plt.figure(figsize=(16, 5))
    
    for i, chrom in enumerate(range(1, 23)):
        chr_data = plot_data[plot_data[chrom_col] == chrom]
        if len(chr_data) == 0:
            continue
        
        x_pos = chr_data['chrom_pos']
        if stat_col:
            y_pos = chr_data[stat_col]
        else:
            y_pos = np.ones(len(chr_data))
        
        plt.scatter(x_pos, y_pos, c=colors[i % 2], s=3, alpha=0.6)
    
    plt.xlabel('Chromosome')
    plt.ylabel('Introgression Signal')
    plt.title(title)
    plt.tight_layout()
    plt.savefig('introgression_manhattan.png', dpi=300)
    plt.show()

# 绘制Manhattan图
plot_manhattan(archaic, title='Neanderthal Introgression Signal')

# =====================================
# 5. 人群间比较
# =====================================

def plot_population_comparison(sample_list, archaic_dir):
    """比较不同人群的渗入比例"""
    
    pops = []
    for sample in sample_list:
        archaic_file = f"{archaic_dir}/{sample}.archaic"
        if not os.path.exists(archaic_file):
            continue
        
        df = pd.read_csv(archaic_file, sep='\t')
        stats = get_chr_stats(df)
        
        total_len = stats['Total_Length'].sum() / 1e6
        neander_len = stats['Neander_Length'].sum() / 1e6
        denisovan_len = stats['Denisovan_Length'].sum() / 1e6
        
        pops.append({
            'Population': sample,
            'Total_Mb': total_len,
            'Neanderthal_Mb': neander_len,
            'Denisovan_Mb': denisovan_len,
            'Neanderthal_pct': neander_len / total_len * 100 if total_len > 0 else 0,
            'Denisovan_pct': denisovan_len / total_len * 100 if total_len > 0 else 0
        })
    
    pop_df = pd.DataFrame(pops)
    
    # 绘图比较
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # 绝对长度
    x = np.arange(len(pop_df))
    width = 0.35
    
    axes[0].bar(x - width/2, pop_df['Neanderthal_Mb'], width, label='Neanderthal', color='darkorange')
    axes[0].bar(x + width/2, pop_df['Denisovan_Mb'], width, label='Denisovan', color='darkgreen')
    axes[0].set_xticks(x)
    axes[0].set_xticklabels(pop_df['Population'], rotation=45)
    axes[0].set_ylabel('Total Length (Mb)')
    axes[0].set_title('Archaic Introgression (Mb)')
    axes[0].legend()
    
    # 百分比
    axes[1].bar(x - width/2, pop_df['Neanderthal_pct'], width, label='Neanderthal', color='darkorange')
    axes[1].bar(x + width/2, pop_df['Denisovan_pct'], width, label='Denisovan', color='dark[1].setgreen')
    axes_xticks(x)
    axes[1].set_xticklabels(pop_df['Population'], rotation=45)
    axes[1].set_ylabel('Percentage (%)')
    axes[1].set_title('Archaic Introgression (%)')
    axes[1].legend()
    
    plt.tight_layout()
    plt.savefig('introgression_comparison.png', dpi=300)
    plt.show()
    
    return pop_df

# 使用
# sample_list = ['Chinese', 'Japanese', 'Korean', 'Vietnamese']
# pop_df = plot_population_comparison(sample_list, './archaic_results/')

print("可视化完成!")
```

## 使用说明

1. **准备数据**:
   - `sample.archaic`: ArchaicSeeker输出的渗入片段文件

2. **运行**:
   ```bash
   python introgression_visualization.py
   ```

3. **输出**:
   - `introgression_by_chr.png`: 各染色体渗入长度
   - `introgression_manhattan.png`: Manhattan-style图
   - `introgression_comparison.png`: 人群间比较(如果有多样本)
