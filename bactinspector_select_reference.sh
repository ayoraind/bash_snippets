#!/bin/bash

# Initialize variables
fastq_dir=""
output_dir=""
fastq_pattern=""

# Define a function to display usage instructions
usage() {
  echo "Usage: $0 -i <fastq_dir> -f <fastq_pattern> -o <output_dir>"
  echo "Options:"
  echo "  -i <fastq_dir>    Specify the input FastQ directory."
  echo "  -f <fastq_pattern>    Specify the input FastQ pattern."
  echo "  -o <output_dir>   Specify the output directory for bactinspector."
  exit 1
}

# Parse command line options
while getopts "i:f:o:" opt; do
  case $opt in
    i)
      fastq_dir="$OPTARG"
      ;;
    f)
      fastq_pattern="$OPTARG"
      ;;
    o)
      output_dir="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Check if both input and output directories are provided
if [ -z "$fastq_dir" ] || [ -z "$output_dir" ]; then
  echo "Error: Input (-i) and/or output (-o) directories not specified."
  usage
fi

# Check if the specified input directory exists
if [ ! -d "$fastq_dir" ]; then
  echo "Error: Fastq pattern (-f) is not specified."
  exit 1
fi

# Check if the specified fastq pattern exists
if [ -z "$fastq_pattern" ]; then
  echo "Error: Input directory '$fastq_dir' not found."
  exit 1
fi

# Check if the specified output directory exists or create it
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir"
  if [ $? -ne 0 ]; then
    echo "Error: Could not create the output directory '$output_dir'."
    exit 1
  fi
fi

# Count the number of genome/FastQ files in the input directory
file_count=$(ls ${fastq_dir} | wc -l )

# Check if there are more than two files
if [ "$file_count" -gt 2 ]; then
  echo "There are more than one paired-end FastQ files in the directory: $file_count files found."
 
  # Run the bactinspector command
  bactinspector_command="bactinspector closest_match -i $fastq_dir -fq '${fastq_pattern}' -o $output_dir"
  echo "Running bactinspector command: $bactinspector_command"
  eval "$bactinspector_command"
  
  ftp_path=$(sed -n '2p' $output_dir/closest_matches_*.tsv | grep -o 'ftp\:\//.*\.gz') 
  
  ftp_path2=$(echo $ftp_path | cut -d'.' -f2-)
  
  curl https://ftp.$ftp_path2 -o $output_dir/reference.fasta.gz
  
  gunzip $output_dir/reference.fasta.gz
  
  # remove plasmid contigs from reference
  awk "/^>/ {n++} n>1 {exit} {print}" $output_dir/reference.fasta > $output_dir/reference_without_plasmids.fas

   
else
  echo "There are less than two paired-end FastQ files in the directory: $file_count files found."
fi
