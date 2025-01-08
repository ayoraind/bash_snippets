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

2. The extract_reads_from_kraken_output.sh is designed to extract reads associated with unique microbes from Kraken output. It facilitates the extraction of specific reads based on taxonomic information, allowing for more targeted analysis downstream.

Dependencies:
extract_kraken_reads.py: A [Python script](https://github.com/jenniferlu717/KrakenTools/blob/master/extract_kraken_reads.py) for extracting reads based on Kraken output. This has to be downloaded and included in the system's PATH.


### Usage:
```
bash extract_reads_from_kraken_output.sh -l <your_list> -k <kraken_directory> -o <output_directory> -p <raw_read_filepath>
```

Options:
-l: Absolute filepath to a TSV/TXT file containing sample information (headerless file containing sample names, taxids, species codes, and species names, in this order, respectively).

-o: Output directory for extracted reads.

-k: Speciation directory where Kraken output files are located (*.out file is the only recognized file).

-p: Absolute filepath to the directory containing raw reads.

-v: Display script version and exit.

-h: Display usage information and exit.

### Example:

```
bash extract_reads_from_kraken_output.sh -l /path/to/sample_list.tsv -k /path/to/kraken_results -o /path/to/output_reads -p /path/to/raw_reads
```

3. The extract_and_rename_unicycler_or_dragonflye_or_plassembler_or_hybracter_contigs.sh script was written to extract contigs from hybrid assemblies, specifically from Unicycler, Dragonflye, Hybracter, and Plassembler. It uses positional arguments, and adheres to the DRY (do not repeat yourself) principle.

Make sure you have the extract-contig.pl script downloaded. You can find more information [here](https://github.com/raymondkiu/bioinformatics-tools/blob/master/extract-contig.pl). This script also assumes that the extract-contig.pl script is in your $PATH. To be sure, following installation, check if you see the file path to the extract-contig.pl script by typing:

```
which extract-contig.pl
```

### Example:

```
bash extract_and_rename_unicycler_or_dragonflye_or_plassembler_or_hybracter_contigs.sh /path/to/headerless_text_file_containing_genome_ids_alone_in_the_first_column.tsv/path/to/directory/containing/hybrid/assembly /path/to/output/directory name_of_tool_in_lowercase
```
