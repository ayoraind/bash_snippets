#!/bin/bash
SPECIES=<SPECIES>
RESFINDER_DB=<RESFINDER_DB>
POINTFINDER_DB=<POINTFINDER_DB>
DISINFINDER_DB=<DISINFINDER_DB>
INPUT_DIR=<INPUT_DIR>
DATA_DIR=<DATA_DIR>

# Function to relabel species
relabel_species() {
    local species=$1
    case "$species" in
        "escherichia_coli")
            echo "Escherichia coli"
            ;;
        "campylobacter_coli")
            echo "Campylobacter coli"
            ;;
        "campylobacter_jejuni")
            echo "Campylobacter jejuni"
            ;;
        "enterococcus_faecalis")
            echo "Enterococcus faecalis"
            ;;
        "enterococcus_faecium")
            echo "Enterococcus faecium"
            ;;
        "helicobacter_pylori")
            echo "Helicobacter pylori"
            ;;
        "mycobacterium_tuberculosis")
            echo "Mycobacterium tuberculosis"
            ;;
        "neisseria_gonorrhoeae")
            echo "Neisseria gonorrhoeae"
            ;;
        "staphylococcus_aureus")
            echo "Staphylococcus aureus"
            ;;
        # For Klebsiella and Salmonella species, return the general names
        klebsiella*)
            echo "Klebsiella"
            ;;
        salmonella*)
            echo "Salmonella"
            ;;
        # Default case - if no match, echo the input as it is (preserving capital letters)
        *)
            echo "other"
            ;;
    esac
}

# Relabel the species based on the function
relabeled_species=$(relabel_species "$SPECIES")

# List of allowed species
allowed_species=("Campylobacter" "Campylobacter coli" "Campylobacter jejuni" \
"Enterococcus faecalis" "Enterococcus faecium" "Escherichia coli" "Helicobacter pylori" \
"Klebsiella" "Mycobacterium tuberculosis" "Neisseria gonorrhoeae" "Salmonella" "Staphylococcus aureus")

# Check if the relabeled species is in the list of allowed species
if [[ " ${allowed_species[@]} " =~ " ${relabeled_species} " ]]; then
    echo "Processing for species: $relabeled_species"
    OUTPUT_DIR=$DATA_DIR/resfinder_output/${SPECIES}/
for each in $(ls $INPUT_DIR/*.fasta); do
    file=$(basename $each)
    filename=${file%.fasta}
    mkdir -p $OUTPUT_DIR/${filename}
    echo "Input file: $filename"
    python -m resfinder -o $OUTPUT_DIR/${filename} -s "${relabeled_species}" -l 0.6 -t 0.8 --acquired --point -ifa $INPUT_DIR/${filename}.fasta -db_res $RESFINDER_DB -db_point $POINTFINDER_DB -db_disinf $DISINFINDER_DB
mv $OUTPUT_DIR/${filename}/ResFinder_results_tab.txt $OUTPUT_DIR/${filename}/${filename}_ResFinder_results_tab.txt
mv $OUTPUT_DIR/${filename}/pheno_table_${SPECIES}.txt $OUTPUT_DIR/${filename}/${filename}_pheno_table_${SPECIES}.txt
mv $OUTPUT_DIR/${filename}/PointFinder_results.txt $OUTPUT_DIR/${filename}/${filename}_PointFinder_results.txt
done
else
	echo "Processing for species that are not ${allowed_species}"
	OTHER_SPECIES="other"
	OUTPUT_DIR=$DATA_DIR/resfinder_output/${OTHER_SPECIES}/
for each in $(ls $INPUT_DIR/*.fasta); do
    file=$(basename $each)
    filename=${file%.fasta}
    mkdir -p $OUTPUT_DIR/${filename}
    echo "Input file: $filename"
    python -m resfinder -o $OUTPUT_DIR/${filename} -s "${OTHER_SPECIES}" -l 0.6 -t 0.8 --acquired --point -ifa $INPUT_DIR/${filename}.fasta -db_res $RESFINDER_DB -db_disinf $DISINFINDER_DB
mv $OUTPUT_DIR/${filename}/ResFinder_results_tab.txt $OUTPUT_DIR/${filename}/${filename}_ResFinder_results_tab.txt
mv $OUTPUT_DIR/${filename}/pheno_table.txt $OUTPUT_DIR/${filename}/${filename}_pheno_table_${OTHER_SPECIES}.txt

done
fi
# clean up
#rm -rf ${OUTPUT_DIR}/tmp_work

echo -e "\nGenerating Resfinder summary report..."
# Create the output file with a header (same as in the individual files + "FILENAME" column)
echo -e "FILENAME\tResistance_gene\tIdentity\tAlignment_Length/Gene_Length\tCoverage\tPosition_in_reference\tContig\tPosition_in_contig\tPhenotype\tAccession_no" > $OUTPUT_DIR/combined_ResFinder_results.tsv

for file in $OUTPUT_DIR/*/*_ResFinder_results_tab.txt
do filename=$(basename "$file" "_ResFinder_results_tab.txt")
	awk -v fname="$filename" 'NR>1 {print fname "\t" $0}' "$file" >> $OUTPUT_DIR/combined_ResFinder_results.tsv
done

# cater for allowable species and "other" for Pointfinder summary report. Skip if species is not part of the allowed_species
if [[ "$relabeled_species" == "other" ]]
then
        echo -e "\nSkip Pointfinder summary report..."
else
echo -e "\nGenerating Pointfinder summary report..."
echo -e "FILENAME\tMutation\tNucleotide_change\tAmino_acid_change\tResistance\tPMID" > $OUTPUT_DIR/combined_PointFinder_results.tsv

for file in $OUTPUT_DIR/*/*_PointFinder_results.txt
do filename=$(basename "$file" "_PointFinder_results.txt")
	awk -v fname="$filename" 'NR>1 {print fname "\t" $0}' "$file" >> $OUTPUT_DIR/combined_PointFinder_results.tsv
done
fi

# The script processes each *_pheno_table_*.txt file.
# It skips lines that start with # but retains the line starting with # Antimicrobial (the header), removes the #, and appends it to the file only once (when processing the first file).
# For each line in the file (that isn't a comment line), it adds the filename (without _pheno_table_*.txt) in the first column and appends the remaining content to the output file.
# It loops through all files and combines them into one combined_pheno_table_summary.tsv file.
echo -e "\nGenerating Phenotype table summary report..."
# Initialize a flag to track if the header has been added
header_added=false

for file in $OUTPUT_DIR/*/*_pheno_table_*.txt
do
	# Extract the filename without the _pheno_table_*.txt part
	if [[ "$relabeled_species" == "other" ]]
then
	filename=$(basename "$file" "_pheno_table_other.txt")
else
    filename=$(basename "$file" "_pheno_table_${SPECIES}.txt")
    fi
    # Process the file
    while read -r line; do
        # Skip all lines that start with "#" except the last header line
        if [[ "$line" =~ ^# ]]; then
            # Check if the line is the header (last one with "#")
            if [[ "$line" =~ ^#\ Antimicrobial ]]; then
                # Remove the "#" from the header
                line="${line/#\# /}"
                # Only add the header once (first file)
                if [[ $header_added == false ]]; then
                    echo -e "FILENAME\t$line" > $OUTPUT_DIR/combined_pheno_table_summary.tsv
                    header_added=true
                fi
            fi
        else
            # Add the filename in the first column and append the data to the output file
            echo -e "$filename\t$line" >> $OUTPUT_DIR/combined_pheno_table_summary.tsv
        fi
    done < "$file"
done
