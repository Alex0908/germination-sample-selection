# Germination Sample Selection Tool

A generalized R-based pipeline for selecting representative samples from large germination datasets using PCA and Kennard-Stone algorithm. Designed to work across different crops and experimental conditions.

## Overview

This tool helps you:
- **Summarize** germination behavior using key descriptors (Gmax, t50, AUC, uniformity, slope)
- **Reduce dimensionality** using Principal Component Analysis (PCA)
- **Select** a uniformly distributed subset of samples that preserves the full diversity of germination behavior
- **Visualize** results through PCA plots, density distributions, and germination curves
- **Scale** to different crops by modifying configuration files

## Why This Approach?

When you have hundreds of germination curves, manually selecting representative samples is impractical. This workflow:

1. **Removes redundancy** - PCA combines correlated descriptors into independent dimensions
2. **Preserves diversity** - Kennard-Stone ensures selected samples span the full range of variation
3. **Is reproducible** - Configuration-driven, version-controlled, and fully documented
4. **Is generalizable** - Works for any crop or experimental dataset with similar structure

## Quick Start

### Prerequisites
```R
# Install required packages
install.packages(c("readxl", "tidyverse", "prospectr", "factoextra"))
```

### Basic Usage

```R
# Load the main pipeline
source("R/00_config.R")
source("R/main_pipeline.R")

# Run the full analysis
run_germination_selection(
  config_file = "config/pepper_example.yml",
  output_dir = "outputs/pepper_run1"
)
```

### Project Structure

```
germination-sample-selection/
├── R/
│   ├── 00_config.R              # Load and validate configuration
│   ├── 01_load_data.R           # Data import and validation
│   ├── 02_select_descriptors.R  # Feature matrix construction
│   ├── 03_run_pca.R             # PCA analysis
│   ├── 04_kennard_stone.R       # Sample selection
│   ├── 05_diagnostics.R         # Validation checks
│   ├── 06_export_results.R      # Output generation
│   └── main_pipeline.R          # Orchestration function
├── config/
│   ├── pepper_example.yml       # Pepper germination config
│   ├── tomato_example.yml       # Tomato germination config (template)
│   └── template_config.yml      # Generic template
├── data/
│   └── examples/
│       ├── pepper_metrics.csv   # Summary descriptors
│       └── pepper_counts.csv    # Time-series germination counts
├── outputs/
│   ├── .gitkeep
│   └── README.md               # Output directory guide
├── docs/
│   ├── workflow.md             # Detailed workflow explanation
│   ├── configuration.md        # How to configure for your crop
│   └── troubleshooting.md      # Common issues
└── README.md                   # This file
```

## Configuration

Adapt the tool to your crop by creating a YAML config file:

```yaml
# config/my_crop_example.yml
crop_name: "Pepper"
experiment_id: "PA-RPC-25C-DA-PM"

# Data input paths
data:
  metrics_file: "data/examples/pepper_metrics.csv"
  counts_file: "data/examples/pepper_counts.csv"

# Descriptor columns for PCA
descriptors:
  - "Gmax"
  - "t50germ"
  - "AUC"
  - "uniformity"
  - "b (slope)"

# PCA settings
pca:
  variance_threshold: 0.90  # Retain 90% of variance
  scale: true              # Standardize variables
  center: true             # Center variables

# Kennard-Stone selection
kennard_stone:
  n_samples: 30            # Number of samples to select
  metric: "mahal"          # Mahalanobis distance

# Visualization settings
plots:
  pca_plot: true
  density_plots: true
  germination_curves: true
  save_png: true
  dpi: 300
```

## Outputs

After running the pipeline, you'll find in your output directory:

- **selected_samples.csv** - IDs and descriptors of selected samples
- **pca_summary.txt** - PCA variance explained and loadings
- **pca_plot.png** - Biplot showing selected vs. unselected samples
- **density_plots.png** - Feature distributions with selected samples highlighted
- **germination_curves.png** - Time-series germination curves
- **selection_report.txt** - Summary statistics and validation checks

## Input Data Format

### Metrics File (CSV)

Required columns:
- A unique identifier (default: "Label" or "Batch")
- Descriptor columns (e.g., Gmax, t50germ, AUC, uniformity, b (slope))
- Optional: crop, treatment, environment, replicate

Example:
```
Label,Gmax,t50germ,AUC,uniformity,b (slope)
I26-0082578.3,97,17.1288,7549.4055,8.0377,7.1519
I26-0087593.3,84,20.9671,6202.6281,8.509,8.2536
```

### Counts File (CSV)

Required columns:
- Batch/sample identifier (must match metrics file)
- Time columns (named "Time 1", "Time 2", etc. or "Time_0", "Time_1", etc.)
- Count columns (named "Count 1", "Count 2", etc. or "Count_0", "Count_1", etc.)
- Alternating time-count pairs

Example:
```
Batch,Time 1,Count 1,Time 2,Count 2,Time 3,Count 3,...
I26-0061515.3,0:00:00,0,18:30:00,0,21:00:00,1.02,...
I26-0061529.3,0:00:00,0,18:30:00,3,21:00:00,8,...
```

## Example Workflows

### For a New Crop

1. Prepare your data in the format specified above
2. Copy `config/template_config.yml` to `config/my_crop.yml`
3. Edit the configuration with your crop name, file paths, and descriptors
4. Run:
   ```R
   source("R/main_pipeline.R")
   run_germination_selection("config/my_crop.yml", "outputs/my_crop_run1")
   ```

### For Different Sample Sizes

Edit the `kennard_stone.n_samples` parameter in your config:
```yaml
kennard_stone:
  n_samples: 50  # Select 50 samples instead of 30
```

### For Different Variance Thresholds

Adjust `pca.variance_threshold`:
```yaml
pca:
  variance_threshold: 0.95  # Retain 95% instead of 90%
```

## Understanding the Results

### PCA Plot
- Each point represents a sample
- **Red points** = selected samples
- **Grey points** = not selected
- Points clustered together have similar germination behavior
- The axes (PC1, PC2, etc.) represent independent germination dimensions

### Density Plots
- Show distribution of each descriptor in the full dataset
- **Red ticks** on x-axis mark the position of selected samples
- Visual confirmation that selected samples span the full range

### Germination Curves
- Time-series germination progression
- **Red lines** = selected samples
- **Grey lines** = all other samples
- Shows whether selection captures the full range of germination dynamics

## Troubleshooting

See `docs/troubleshooting.md` for common issues and solutions.

## Citation

If you use this tool in your research, please cite:

```
Kennard, R. W., & Stone, L. A. (1966). Computer aided design of experiments. 
Technometrics, 8(3), 415-426.

Jolliffe, I. T. (2002). Principal Component Analysis (2nd ed.). 
Springer-Verlag.
```

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please submit issues or pull requests to improve the tool for other crops and use cases.

## Author

Created by Alex0908 for pepper germination studies. Extended for multiple crops.

---

**Last Updated:** 2026-09-29
