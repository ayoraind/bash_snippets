#!/bin/bash

set -e

usage() {
        echo
        echo "###### This script is used for extracting reads (associated with unique microbes) from kraken output #####"
        echo "usage : bash extract_reads_from_kraken_output.sh -l <your_list> -k <kraken_directory> -o <output_directory> -p <raw_read_filepath>"
        echo
        echo "options :"
        echo "-l        absolute filepath to tsv/txt file containing (in the following order of columns) sample names (e.g., T015-49BE-G221111), taxid (e.g.,, 562) species code (e.g., eco), and species name (separated by underscore, e.g., escherichia_coli), without headers"
        echo "-o        Output directory for extracted reads (e.g., /MIGE/01_DATA/01_FASTQ)"
	echo "-k        speciation directory (e.g., /MIGE/01_DATA/06_SPECIES_CHECK)"
	echo "-p        absolute filepath to directory containing raw reads (e.g., /MIGE/01_DATA/01_FASTQ)"
	echo "-v        Display version and exit"
        echo "-h        Display this help and exit"
        echo
}


version(){
	echo
	echo "SCRIPT_VERSION='extract_reads_from_kraken_output.sh v.0.1.0'"
	echo
}

while getopts "l:o:k:p:vh" option; do
        case "${option}" in
                l) LIST=${OPTARG};;
                o) OUTDIR=${OPTARG};;
		k) SPECIATIONDIR=${OPTARG};;
		p) READDIR=${OPTARG};;
		v) # echo script version 
		   	version
			exit;;
                h) # display usage
                        usage
                        exit;;
		:) printf "missing argument for -$OPTARG\n" >&2; exit 1;;
                \?) # incorrect option
                        echo "Error: Invalid option"
                        usage
                        exit;;
        esac
done

# here, shift removes positional parameters. Thus shift $((OPTIND-1)) removes all the options that have been parsed by getopts from the parameters list, and so after that point, $1 will refer to the first non-option argument passed to the script.

shift "$((OPTIND-1))"

# timestamp for each process
TIMESTAMP_PROCESS="`date '+%d-%m-%Y  %H:%M:%S'`"

# Check missing arguments
MISSING="is missing but required. Exiting."
if [ -z ${LIST+x} ]; then echo "-l $MISSING"; usage; exit 1; fi; 
if [ -z ${OUTDIR+x} ]; then echo "-o $MISSING"; usage; exit 1; fi; 
if [ -z ${SPECIATIONDIR+x} ]; then echo "-k $MISSING"; usage; exit 1; fi;
if [ -z ${READDIR+x} ]; then echo "-p $MISSING"; usage; exit 1; fi; 

# check wrong directories stated
ABSENT="No such file or directory"
if [[ ! -d ${READDIR} ]]; then echo "$ABSENT. Kindly check if the filepath ${READDIR} is correct and try again"; exit 1; fi;
if [[ ! -d ${OUTDIR} ]]; then echo "$ABSENT. Kindly check the filepath ${OUTDIR} is correct and try again"; exit 1; fi;
if [[ ! -d ${SPECIATIONDIR} ]]; then echo "$ABSENT. Kindly check the filepath ${SPECIATIONDIR} is correct and try again"; exit 1; fi;
if [[ ! -f ${LIST} ]]; then echo "$ABSENT. Kindly check the filepath ${LIST} is correct and try again"; exit 1; fi;

# extract reads

while read line
do

samplename=$(echo $line | awk '{print $1}')
taxid=$(echo $line | awk '{print $2}')
species_code=$(echo $line | awk '{print $3}')
species=$(echo $line | awk '{print $4}')
# extract actual sample name (e.g T025), week, and site at once
samplecode=$(echo $line | awk '{print $1}' | cut -d'_' -f1)
# extract sequencing date from sample name
sequencingdate=$(echo $line | awk '{print $1}' | cut -d'_' -f2)

if [[ -f ${OUTDIR}/${samplecode}-${species_code}_${sequencingdate}.fastq.gz ]]
then
echo "${OUTDIR}/${samplecode}-${species_code}_${sequencingdate}.fastq.gz file exists. Skipping ..."

else 

echo ">> EXTRACTING READS CORRESPONDING TO" $species "FROM" $samplename "WITH TAXID" $taxid "INTO" ${samplecode}-${species_code}_${sequencingdate}.fastq

echo "PROGRAM START TIME:" $TIMESTAMP_PROCESS
# extract reads
extract_kraken_reads.py -k ${SPECIATIONDIR}/${samplename}.kraken.out -t $taxid -o ${OUTDIR}/${samplecode}-${species_code}_${sequencingdate}.fastq --fastq-output -s ${READDIR}/${samplename}.fastq.gz --include-children -r ${SPECIATIONDIR}/${samplename}.kraken.report.txt

# gzip file
gzip ${OUTDIR}/${samplecode}-${species_code}_${sequencingdate}.fastq

echo "PROGRAM END TIME:" $TIMESTAMP_PROCESS

fi

done < ${LIST}
