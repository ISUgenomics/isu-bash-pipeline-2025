module purge
module load fastqc

INPUT_DIR=01_data
OUTPUT_DIR=02c_fastqc_loop_samplename
LOG_DIR=logs

mkdir -p $OUTPUT_DIR

for file in $INPUT_DIR/*.fastq.gz 
do  
  sample_id=$(basename "$file" .fastq.gz)
  echo "Running FastQC on: $sample_id"
  fastqc $file -o $OUTPUT_DIR/ > $LOG_DIR/02_fastqc_loop_$sample_id.log 2>&1
done