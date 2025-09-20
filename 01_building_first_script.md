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

#### Multiple files (GNU Parallel)

Let us now use GNU Parallel to run the FastQC analysis on all files in parallel.
The first step is go for a dry run to see what commands will be executed.

```bash
module load parallel 
mkdir -p 02d_fastqc_parallel
parallel --dry-run -j 8 fastqc {} -o 02d_fastqc_parallel/ &> logs/02_fastqc_parallel.log ::: 01_data/*.fastq.gz
```

- `parallel --dry-run -j 8 fastqc {} -o 02d_fastqc_parallel/ ::: 01_data/*.fastq.gz`
  - `--dry-run` prints the commands that would be executed, without running them. Use this to verify first.
  - `-j 8` means run up to 8 jobs at the same time (choose based on cores available to you).
  - `fastqc {}` is the command template; `{}` will be replaced by each input filename.
  - `-o 02d_fastqc_parallel/` sends FastQC outputs into that directory.
  - `:::` introduces the list of inputs to feed to GNU Parallel; here the shell expands `01_data/*.fastq.gz` to all matching files.
- `&> logs/02_fastqc_parallel.log` captures both stdout and stderr into the log file so you can review what happened.

To actually run the commands (not just show them), remove `--dry-run`:

```bash
module load parallel
mkdir -p 02d_fastqc_parallel
basename=$(basename "$file" .fastq.gz)
parallel -j 8 fastqc {} -o 02d_fastqc_parallel/ &> logs/02_fastqc_parallel_$basename.log ::: 01_data/*.fastq.gz
```

Add the above script to `00_scripts/04_fastqc_parallel.sh`.

Make it executable:

```bash
chmod +x 00_scripts/04_fastqc_parallel.sh
```

Run the script:

```bash
time ./00_scripts/04_fastqc_parallel.sh
```

<details>
<summary>Output</summary>
<pre>
real    0m26.453s
user    2m1.143s
sys     0m3.962s
</pre>
</details>

- **What these mean**
  - `real`: Wall-clock time — how long the command took from start to finish in the real world (what you waited).
  - `user`: Total CPU time spent running your program’s code in user space. With multiple cores or parallel jobs, this is the sum across all processes/cores and can be greater than `real`.
  - `sys`: CPU time spent in the kernel (e.g., doing I/O, file operations).

- **Why `user` > `real` here**
  - Because we ran multiple tasks concurrently (e.g., via loops or GNU Parallel), CPU time across cores adds up. If 8 cores each do ~15 seconds of work, `user` could be ~120 seconds while `real` is ~15–30 seconds.

- **How to interpret**
  - Use `real` to estimate elapsed time for the end-to-end run (what you experience).
  - Use `user + sys` to gauge how much total CPU work was consumed. Large gaps between `real` and `user+sys` often indicate parallelism; very small `user`/`sys` compared to `real` can indicate waiting on I/O.
