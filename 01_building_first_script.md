# Running commands and making a script of the commands run

### What is a head node?

- A head node is a node that is used to control the cluster.
- It is the node that you will be using to run your commands.
- It is the node that will be used to submit your jobs to the cluster.

### What is a compute node?

- A compute node is a node that is used to run your jobs.
- It is the node that will be used to run your jobs.

### What is a job?

- A job is a task that is run on a compute node.

### What are the files in the data folder?

```bash
ls 01_data/
```

<details>
<summary>Output</summary>
<pre>
bio_sample_01_R1.fastq.gz  bio_sample_02_R1.fastq.gz  bio_sample_03_R1.fastq.gz  bio_sample_04_R1.fastq.gz  bio_sample_05_R1.fastq.gz
bio_sample_01_R2.fastq.gz  bio_sample_02_R2.fastq.gz  bio_sample_03_R2.fastq.gz  bio_sample_04_R2.fastq.gz  bio_sample_05_R2.fastq.gz
</pre>
</details>

### Checking the quality of the reads using FastQC

#### One file

```bash
mkdir -p 02_fastqc
fastqc 01_data/bio_sample_01_R1.fastq.gz -o 02_fastqc/
```
-p flag is used to create the directory if it does not exist.

Once the program is run, it will create a directory called `02_fastqc` and put the output files in it.

```bash
ls 02_fastqc
```

<details>
<summary>Output</summary>
<pre>
bio_sample_01_R1_fastqc.html  bio_sample_01_R1_fastqc.zip
</pre>
</details>

Remove the folders created

```bash
rm -rf 02_fastqc
```

##### Add the command to a script and save it as `01_fastqc.sh` in `00_scripts` directory.

```bash
cat 00_scripts/01_fastqc.sh
```

<details>
<summary>Output</summary>
<pre>
mkdir -p logs
mkdir -p 02_fastqc
fastqc 01_data/bio_sample_01_R1.fastq.gz -o 02_fastqc/ &> logs/01_fastqc.log
</pre>
</details>

##### Make the script an executable file

```bash
chmod +x fastqc_01.sh
```

##### Run the script

```bash
./fastqc_01.sh
```

#### Multiple files (looping through files)

A simple example:

```bash
# A simple loop example: list files in 01_data/
for file in 01_data/*.fastq.gz; 
do
  echo "Found file: $file"
done
```

The `for ... in ...; do ... done` construct repeats the commands between `do` and `done` for each matched file.

`01_data/*.fastq.gz` expands (globs) to all FASTQ files in the `01_data/` directory.

`$file` is a shell variable that holds the current filename; `echo` prints text to the terminal.

Run `FastQC` on all files in `01_data/`:

```bash
mkdir -p 02b_fastqc_loop

for file in 01_data/*.fastq.gz; do
  echo "Running FastQC on: $file"
  fastqc $file -o 02b_fastqc_loop/ &> logs/02_fastqc_loop.log
done
```

Save this script as `02_fastqc_loop.sh` in `00_scripts` directory.

Make it executable:

```bash
chmod +x 02_fastqc_loop.sh
```

##### Run the script

```bash
time ./00_scripts/02_fastqc_loop.sh
```

<details>
<summary>Output</summary>
<pre>
Running FastQC on: 01_data/bio_sample_01_R1.fastq.gz
Running FastQC on: 01_data/bio_sample_01_R2.fastq.gz
Running FastQC on: 01_data/bio_sample_02_R1.fastq.gz
Running FastQC on: 01_data/bio_sample_02_R2.fastq.gz
Running FastQC on: 01_data/bio_sample_03_R1.fastq.gz
Running FastQC on: 01_data/bio_sample_03_R2.fastq.gz
Running FastQC on: 01_data/bio_sample_04_R1.fastq.gz
Running FastQC on: 01_data/bio_sample_04_R2.fastq.gz
Running FastQC on: 01_data/bio_sample_05_R1.fastq.gz
Running FastQC on: 01_data/bio_sample_05_R2.fastq.gz

real    1m12.560s
user    1m37.585s
sys     0m2.792s
</pre>
</details>

Check the log file:

```bash
cat logs/02_fastqc_loop.log
```

<details>
<summary>Output</summary>
<pre>
Started analysis of bio_sample_05_R2.fastq.gz
Approx 5% complete for bio_sample_05_R2.fastq.gz
Approx 10% complete for bio_sample_05_R2.fastq.gz
Approx 15% complete for bio_sample_05_R2.fastq.gz
Approx 20% complete for bio_sample_05_R2.fastq.gz
Approx 25% complete for bio_sample_05_R2.fastq.gz
Approx 30% complete for bio_sample_05_R2.fastq.gz
Approx 35% complete for bio_sample_05_R2.fastq.gz
Approx 40% complete for bio_sample_05_R2.fastq.gz
Approx 45% complete for bio_sample_05_R2.fastq.gz
Approx 50% complete for bio_sample_05_R2.fastq.gz
Approx 55% complete for bio_sample_05_R2.fastq.gz
Approx 60% complete for bio_sample_05_R2.fastq.gz
Approx 65% complete for bio_sample_05_R2.fastq.gz
Approx 70% complete for bio_sample_05_R2.fastq.gz
Approx 75% complete for bio_sample_05_R2.fastq.gz
Approx 80% complete for bio_sample_05_R2.fastq.gz
Approx 85% complete for bio_sample_05_R2.fastq.gz
Approx 90% complete for bio_sample_05_R2.fastq.gz
Approx 95% complete for bio_sample_05_R2.fastq.gz
Approx 100% complete for bio_sample_05_R2.fastq.gz
Analysis complete for bio_sample_05_R2.fastq.gz
</pre>
</details>

The log file shows the progress of the FastQC analysis for just the last file.

Let us now make sure that we have a log file for each file. 

```bash
mkdir -p 02c_fastqc_loop_basename
for file in 01_data/*.fastq.gz; 
do  
  basename=$(basename "$file" .fastq.gz)
  echo "Running FastQC on: $basename"
  fastqc $file -o 02c_fastqc_loop_basename/ &> logs/02_fastqc_loop$basename.log
done
```

