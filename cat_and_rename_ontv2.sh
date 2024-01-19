#!/bin/bash
echo "Hello. I am a shell script concatenating and renaming ONT file names."

RAW_READ=$1
TEXT_FILEPATH=$2

if (( $# < 2 ))
then
  echo -e "Usage: You need to supply the filepath to the raw reads (first argument) and file path to the text file (second argument), in the stated order\nThat is, bash cat_and_rename_ont.sh /raw_read/filepath /text/filepath.txt"
  exit 1

else
while  IFS=$'\t' read -r sample_name barcode_directory poolname GridION_sequencing_date
do 
    # Concatenate PoolA and PoolB. 
    if [[ $poolname == "AB" ]] && [[ -d "${RAW_READ}/Pools/PoolA/${barcode_directory}" ]] && [[ -d "${RAW_READ}/Pools/PoolB/${barcode_directory}" ]]
    then
    	if [[ -z "$(ls -A "${RAW_READ}/Pools/PoolA/${barcode_directory}")" ]] && [[ -z "$(ls -A "${RAW_READ}/Pools/PoolB/${barcode_directory}")" ]]
	then
		echo "fastq files are not present in ${barcode_directory} within PoolA or PoolB. Skipping ..."
	elif [[ ! -z "$(ls -A "${RAW_READ}/Pools/PoolA/${barcode_directory}")" ]] && [[ -z "$(ls -A "${RAW_READ}/Pools/PoolB/${barcode_directory}")" ]]
	then
		echo "concatenating $barcode_directory into $sample_name. fastq file does not exist in $barcode_directory within poolB."
        	/usr/bin/cat ${RAW_READ}/Pools/PoolA/${barcode_directory}/*.fastq.gz > ${RAW_READ}/${sample_name}.fastq.gz
	elif [[ -z "$(ls -A "${RAW_READ}/Pools/PoolA/${barcode_directory}")" ]] && [[ ! -z "$(ls -A "${RAW_READ}/Pools/PoolB/${barcode_directory}")" ]]
	then
		echo "concatenating $barcode_directory into $sample_name. fastq file does not exist in $barcode_directory within poolA."
        	/usr/bin/cat ${RAW_READ}/Pools/PoolB/${barcode_directory}/*.fastq.gz > ${RAW_READ}/${sample_name}.fastq.gz
	else
		echo "concatenating $barcode_directory into $sample_name."
        	/usr/bin/cat ${RAW_READ}/Pools/PoolA/${barcode_directory}/*.fastq.gz ${RAW_READ}/Pools/PoolB/${barcode_directory}/*.fastq.gz > ${RAW_READ}/${sample_name}.fastq.gz
	fi
    elif [[ $poolname == "CD"  ]] && [[ -d "${RAW_READ}/Pools/PoolC/${barcode_directory}" ]] && [[ -d "${RAW_READ}/Pools/PoolD/${barcode_directory}" ]]
    then
    	if [[ -z "$(ls -A "${RAW_READ}/Pools/PoolC/${barcode_directory}")" ]] && [[ -z "$(ls -A "${RAW_READ}/Pools/PoolD/${barcode_directory}")" ]]
	then
		echo "fastq files are not present in ${barcode_directory} within PoolC or PoolD. Skipping ..."
	elif [[ -z "$(ls -A "${RAW_READ}/Pools/PoolC/${barcode_directory}")" ]] && [[ ! -z "$(ls -A "${RAW_READ}/Pools/PoolD/${barcode_directory}")" ]]
	then
		echo "concatenating $barcode_directory into $sample_name. fastq file does not exist in $barcode_directory within poolC."
        	/usr/bin/cat ${RAW_READ}/Pools/PoolD/${barcode_directory}/*.fastq.gz > ${RAW_READ}/${sample_name}.fastq.gz
	elif [[ ! -z "$(ls -A "${RAW_READ}/Pools/PoolC/${barcode_directory}")" ]] && [[ -z "$(ls -A "${RAW_READ}/Pools/PoolD/${barcode_directory}")" ]]
	then
		echo "concatenating $barcode_directory into $sample_name. fastq file does not exist in $barcode_directory within poolD."
        	/usr/bin/cat ${RAW_READ}/Pools/PoolC/${barcode_directory}/*.fastq.gz > ${RAW_READ}/${sample_name}.fastq.gz
	else
		echo "concatenating $barcode_directory into $sample_name."
        	/usr/bin/cat ${RAW_READ}/Pools/PoolC/${barcode_directory}/*.fastq.gz ${RAW_READ}/Pools/PoolD/${barcode_directory}/*.fastq.gz > ${RAW_READ}/${sample_name}.fastq.gz
	fi
    elif [[ $poolname == "A" ]] && [[ -d "${RAW_READ}/Pools/PoolA/${barcode_directory}" ]]
    then
    	if [[ -z "$(ls -A "${RAW_READ}/Pools/PoolA/${barcode_directory}")" ]]
	then
		echo "fastq files are not present in ${barcode_directory} within PoolA. Skipping ..." 
	else
		echo "concatenating $barcode_directory into $sample_name."
        	/usr/bin/cat ${RAW_READ}/Pools/PoolA/${barcode_directory}/*.fastq.gz > ${RAW_READ}/${sample_name}.fastq.gz
	fi
    elif [[ $poolname == "B" ]] && [[ -d "${RAW_READ}/Pools/PoolB/${barcode_directory}" ]]
    then
    	if [[ -z "$(ls -A "${RAW_READ}/Pools/PoolB/${barcode_directory}")" ]]
	then
		echo "fastq files are not present in ${barcode_directory} within PoolB. Skipping ..." 
	else
		echo "concatenating $barcode_directory into $sample_name."
        	/usr/bin/cat ${RAW_READ}/Pools/PoolB/${barcode_directory}/*.fastq.gz > ${RAW_READ}/${sample_name}.fastq.gz
	fi
    elif [[ $poolname == "C" ]] && [[ -d "${RAW_READ}/Pools/PoolC/${barcode_directory}" ]]
    then
    	if [[ -z "$(ls -A "${RAW_READ}/Pools/PoolC/${barcode_directory}")" ]]
	then
		echo "fastq files are not present in ${barcode_directory} within PoolC. Skipping ..." 
	else
		echo "concatenating $barcode_directory into $sample_name."
        	/usr/bin/cat ${RAW_READ}/Pools/PoolC/${barcode_directory}/*.fastq.gz > ${RAW_READ}/${sample_name}.fastq.gz
	fi
    elif [[ $poolname == "D" ]] && [[ -d "${RAW_READ}/Pools/PoolD/${barcode_directory}" ]]
    then
    	if [[ -z "$(ls -A "${RAW_READ}/Pools/PoolD/${barcode_directory}")" ]]
	then
		echo "fastq files are not present in ${barcode_directory} within PoolD. Skipping ..." 
	else
		echo "concatenating $barcode_directory into $sample_name."
        	/usr/bin/cat ${RAW_READ}/Pools/PoolD/${barcode_directory}/*.fastq.gz > ${RAW_READ}/${sample_name}.fastq.gz
	fi
    else
    	echo "${barcode_directory} does not exist"
    fi
    
done < $TEXT_FILEPATH
fi

# remove barcodes
rm -rf ${RAW_READ}/Pools/Pool{A,B,C,D}/*
