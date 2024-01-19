TEXT_FILEPATH=$1
# this captures e.g GYYMMDD
SEQUENCING_DATE=$(echo $(basename $(basename ${TEXT_FILEPATH}) .txt) | cut -d'_' -f4)
RAW_READ_DIR=/MIGE/01_DATA/01_FASTQ
	
while read line
do
	NAME=$(echo $line | awk '{print $1}')
	BARCODE=$(echo $line | awk '{print $2}')
	POOL=$(echo $line | awk '{print $3}')
	DATE_GRIDION=$(echo $line | awk '{print $4}')
	
	# check that run has not been copied previously
	if grep -q $SEQUENCING_DATE ${RAW_READ_DIR}/.copied_runs.txt
	then
	# run already copied
	echo "Run for $SEQUENCING_DATE already exists in $RAW_READ_DIR. Unable to retrieve barcodes from GridION successfully"
	# include message in a file
	echo "Run for $SEQUENCING_DATE already exists in $RAW_READ_DIR" > ${RAW_READ_DIR}/.error_message_grid.txt
	exit
	
	else
	
	if [[ ${POOL} == "A" ]]
	then
		echo "retrieving ${BARCODE} from poolA"
		rsync -Pa --ignore-existing -e 'ssh' grid@193.196.238.19:/data/$DATE_GRIDION/*A/*/fastq_pass/${BARCODE} ${RAW_READ_DIR}/Pools/PoolA
	elif [[ ${POOL} == "B" ]]
	then
		echo "retrieving ${BARCODE} from poolB"
		rsync -Pa --ignore-existing -e 'ssh' grid@193.196.238.19:/data/$DATE_GRIDION/*B/*/fastq_pass/${BARCODE} ${RAW_READ_DIR}/Pools/PoolB
        elif [[ ${POOL} == "C" ]]
        then
                echo "retrieving ${BARCODE} from poolC"
                rsync -Pa --ignore-existing -e 'ssh' grid@193.196.238.19:/data/$DATE_GRIDION/*C/*/fastq_pass/${BARCODE} ${RAW_READ_DIR}/Pools/PoolC
	elif [[ ${POOL} == "D" ]]
        then
                echo "retrieving ${BARCODE} from poolD"
                rsync -Pa --ignore-existing -e 'ssh' grid@193.196.238.19:/data/$DATE_GRIDION/*D/*/fastq_pass/${BARCODE} ${RAW_READ_DIR}/Pools/PoolD
	elif [[ ${POOL} == "AB" ]]
        then
                echo "retrieving ${BARCODE} from poolA and poolB"
                rsync -Pa --ignore-existing -e 'ssh' grid@193.196.238.19:/data/$DATE_GRIDION/*A/*/fastq_pass/${BARCODE} ${RAW_READ_DIR}/Pools/PoolA
		rsync -Pa --ignore-existing -e 'ssh' grid@193.196.238.19:/data/$DATE_GRIDION/*B/*/fastq_pass/${BARCODE} ${RAW_READ_DIR}/Pools/PoolB
	elif [[ ${POOL} == "CD" ]]
	then
		echo "retrieving ${BARCODE} from poolC and poolD"
                rsync -Pa --ignore-existing -e 'ssh' grid@193.196.238.19:/data/$DATE_GRIDION/*C/*/fastq_pass/${BARCODE} ${RAW_READ_DIR}/Pools/PoolC
		rsync -Pa --ignore-existing -e 'ssh' grid@193.196.238.19:/data/$DATE_GRIDION/*D/*/fastq_pass/${BARCODE} ${RAW_READ_DIR}/Pools/PoolD
	else
		echo "no such POOL exists within the GridION server"
	fi
	
	fi

done < ${TEXT_FILEPATH}


# update log of copied files
echo $SEQUENCING_DATE >> ${RAW_READ_DIR}/.copied_runs.txt
