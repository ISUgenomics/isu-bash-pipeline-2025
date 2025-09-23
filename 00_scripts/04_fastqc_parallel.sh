module purge
module load parallel
module load fastqc 

mkdir -p 02d_fastqc_parallel
# samplename=$(basename "$file" .fastq.gz)
parallel -j10 \
  'fastqc {1} -o 02d_fastqc_parallel/ > logs/02_fastqc_parallel_{1/.}.log 2>&1' \
  ::: 01_data/*.fastq.gz
