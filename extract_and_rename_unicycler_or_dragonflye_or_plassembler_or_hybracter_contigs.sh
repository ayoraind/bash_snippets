#!/usr/bin/env bash

# trying to follow the DRY principle (Do not Repeat Yourself)
echo "Hello. I am a shell script extracting and renaming unicycler, dragonflye, plassembler, or hybracter fasta contigs."

HEADERLESS_TEXTFILE=$1
INPUT_DIR=$2
OUTDIR=$3
TOOL=$4

if (( $# < 4 )); then
  echo -e "Usage: You need to supply the filepath to the text file (first argument), input directory (second argument) and output directory (third argument), in the stated order\nThat is, bash /path/to/extract_and_rename_unicycler_contigs.sh /path/to/textfile /path/to/inputdir /path/to/outdir <lowercase_name_of_tool>"
  exit 1
fi


# Check if the output directory exists, if not, create it
if [[ ! -d "$OUTDIR" ]]; then
  echo "Output directory does not exist. Creating directory: $OUTDIR"
  mkdir -p "$OUTDIR"  # The -p flag creates any necessary parent directories
fi

# Function to process the contigs
process_contigs() {
  local tool=$1
  local input_file=$2
  local output_prefix=$3
  local output_suffix=$4

  while read line; do
    SAMPLENAME=$(echo $line | awk '{print $1}')
    
    # Handle different naming conventions for input files
    if [[ "$tool" == "hybracter" || "$tool" == "plassembler" ]]; then
      input_file_path="${INPUT_DIR}/${SAMPLENAME}_${input_file}"
    else
      input_file_path="${INPUT_DIR}/${SAMPLENAME}.${input_file}"
    fi
    
    # Ensure the input file exists before proceeding
    if [[ ! -f "$input_file_path" ]]; then
      echo "Error: File $input_file_path not found!"
      continue
    fi

    grep ">" "$input_file_path" | cut -d'>' -f2 > "${OUTDIR}/${SAMPLENAME}_${output_prefix}_contigs.txt"

    while read liney; do
      contig_name=$(echo $liney | cut -d' ' -f1)
      contig_length=$(echo $liney | cut -d' ' -f2 | cut -d'=' -f2)

      extract-contig.pl single "${liney}" "$input_file_path" > "${OUTDIR}/${SAMPLENAME}_${output_suffix}${contig_name}_LENGTH_${contig_length}.fa"
    done < "${OUTDIR}/${SAMPLENAME}_${output_prefix}_contigs.txt"
  done < ${HEADERLESS_TEXTFILE}
  echo "Contigs extracted. Check ${OUTDIR}"
}

# Main logic based on tool type
case $TOOL in
  "dragonflye")
    process_contigs "dragonflye" "reoriented.fa" "dragonflyehybrid" ""
    ;;
  "unicycler")
    process_contigs "unicycler" "scaffolds.fa" "plasmids" "NODE"
    ;;
  "hybracter")
    process_contigs "hybracter" "final.fasta" "final" ""
    ;;
  "plassembler")
    process_contigs "plassembler" "plasmids.fasta" "plasmids" "NODE"
    ;;
  *)
    echo "Unsupported tool: $TOOL"
    exit 1
    ;;
esac
