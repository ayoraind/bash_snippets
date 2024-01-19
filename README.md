## Bash code snippets for quick microbial genomics analysis (bioinformatics).

## Introduction
This repository contains three (and counting) bash snippets for downstream analysis of WGS data.  
1. The bactinspector_select_reference.sh script is designed to facilitate the usage of the [Bactinspector tool](https://gitlab.com/antunderwood/bactinspector), by selecting the best reference genome for SNP phylogeny analysis. It accepts an input directory containing fastq.gz files using the `-i` argument, fastq.gz pattern using the `-f` argument, and the `-o` argument for specifying the output directory. 

Make sure you have the Bactinspector tool installed. You can find more information and installation instructions [here](https://gitlab.com/antunderwood/bactinspector) or [here](https://pypi.org/project/BactInspectorMax/). This script also assumes that the bactinspector tool is in your $PATH. To be sure, following installation, check if you see the file path to the bactinspector tool by typing:

```
which bactinspector
```

### Sample command
An example of a command to run this code snippet is:

```
./bactinspector_pipeline.sh -i /path/to/fastq_files -f "*_R1.fastq.gz" -o /path/to/output_directory

```

### Workflow
**Input Validation:** Checks if both input and output directories are provided.

**Check Input Directory:** Verifies if the specified input directory exists.

**Check Fastq Pattern:** Ensures that the fastq pattern is specified.

**Create Output Directory:** Checks if the specified output directory exists; if not, creates it.

**Run Bactinspector:** Executes Bactinspector's `closest_match` command using the provided inputs.

**Download Reference Genome:** Retrieves the reference genome identified by Bactinspector from an FTP link.

**Remove Plasmid Contigs:** Removes plasmid contigs from the downloaded reference genome.
