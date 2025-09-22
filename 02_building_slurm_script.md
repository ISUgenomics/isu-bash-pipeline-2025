# Building a SLURM script

SLURM (Simple Linux Utility for Resource Management) is the job scheduler that manages who gets to use the cluster’s compute nodes and for how long. You will log in to a head/login node to prepare your work, and then ask SLURM to run your jobs on compute nodes with the resources you request.

If you remember just one thing: you don’t run heavy work directly on the head node. You ask SLURM to run it for you on a compute node.

---

## Why do we use SLURM?

- It shares the cluster fairly among many users.
- It finds and reserves the resources you need (CPUs, memory, time).
- It tracks your job, captures logs, and reports status.

---

## Key words

- **Cluster**: Many connected computers that can work in parallel.
- **Head/Login node**: Where you log in, write scripts, submit jobs. Do not run heavy jobs here.
- **Compute node**: Where your jobs actually run.
- **Job**: A task you ask SLURM to run. It gets a numeric Job ID.
- **Partition (queue)**: A grouping of nodes with certain limits (e.g., time, size). You submit jobs to a partition.
- **Account**: The project or allocation that pays for/authorizes compute usage.
- **Resources**: CPUs/cores, memory (RAM), time limit.
- **Job states**: PENDING (waiting), RUNNING, COMPLETED, FAILED/CANCELLED.

---

## Two ways to use SLURM

- **Batch job (sbatch)**: You submit a script and SLURM runs it in the background on a compute node. Best for pipelines.
- **Interactive job (srun)**: You request a shell on a compute node for hands-on work or quick testing.

---

## Essential commands

```bash
# What is running right now for me?
squeue -u $USER

# What partitions exist? (short summary)
sinfo

# Cancel a job by its Job ID
scancel <JOBID>

# Show info about a job
scontrol show job <JOBID>
```

Tip: Use `history | grep sbatch` to find previous submissions.

---

## Interactive jobs (quick testing)

If you want a short interactive session on a compute node:

**srun**

```bash
srun --account=short_term --partition=interactive \
     --time=00:15:00 --cpus-per-task=2 --mem=2G \
     --pty bash
```

You’ll get a shell on a compute node where you can run commands interactively. Exit with `exit` or Ctrl-D.

---

## Running a SLURM job

We are going to use the `05_fastqc_parallel_improved.sh` script as an example. In the `05_fastqc_parallel_improved.sh` script, change the output directory to `02f_fastqc_slurm`.

```bash
#!/usr/bin/env bash

# ===== SLURM directives (read by the scheduler) =====
#SBATCH --job-name=fastqc            # a short name for your job
#SBATCH --account=short_term              # account/allocation
#SBATCH --partition=interactive           # partition/queue
#SBATCH --time=00:05:00                   # max wall time (hh:mm:ss)
#SBATCH --nodes=1                         # number of nodes
#SBATCH --cpus-per-task=10                 # number of CPU cores
#SBATCH --mem=8G                          # memory per node
#SBATCH --output=logs/%x_%j.out           # STDOUT (%x=job-name, %j=jobid)
#SBATCH --error=logs/%x_%j.err            # STDERR
#SBATCH --mail-user=user@iastate.edu  # email address
#SBATCH --mail-type=ALL                   # send email on all events, BEGIN, END, FAIL

set -euo pipefail

00_scripts/05_fastqc_parallel_improved.sh
```

**Explanation of the directives above**

- `#SBATCH --job-name=fastqc`
  - Short, human-friendly job name. Appears in `squeue`, logs, and emails.

- `#SBATCH --account=short_term`
  - Allocation/account to charge; required to authorize the job.

- `#SBATCH --partition=interactive`
  - Which queue/partition to use. Partitions differ in limits and availability.

- `#SBATCH --time=00:05:00`
  - Maximum wall-clock time. SLURM will stop the job if it exceeds 5 minutes.

- `#SBATCH --nodes=1`
  - Number of compute nodes requested. Most single-node tools/pipelines use 1.

- `#SBATCH --cpus-per-task=10`
  - CPU cores available to your task. Match this to your internal parallelism (e.g., GNU Parallel `-j 10` or a tool’s `--threads 10`).

- `#SBATCH --mem=8G`
  - Total memory on the node reserved for your job. Ensure it covers the peak combined usage of all concurrent processes.

- `#SBATCH --output=logs/%x_%j.out`
  - File for standard output (STDOUT). `%x` = job name, `%j` = job ID (e.g., `logs/fastqc_8249780.out`).

- `#SBATCH --error=logs/%x_%j.err`
  - File for standard error (STDERR). Check here for module load messages and errors.

- `#SBATCH --mail-user=user@iastate.edu`
  - Email address to receive job notifications.

- `#SBATCH --mail-type=ALL`
  - When to send emails. `ALL` includes `BEGIN`, `END`, `FAIL`. You can choose a subset like `END,FAIL` to reduce email volume.

Notes:
- If you launch 10 FastQC processes in parallel, `--cpus-per-task=10` is appropriate; otherwise, lower it to match your actual concurrency.
- Memory must scale with concurrency. If each process needs ~1G and you run 10 in parallel, consider `--mem=10G` or more.
- The job starts in the submission directory by default; to be explicit, add `cd "$SLURM_SUBMIT_DIR"` near the top of the script.

Save the above script as `06_fastqc.slurm` in `00_scripts` directory.

**How to submit and check:**

```bash
sbatch 00_scripts/06_fastqc.slurm
```

**Check the status of the job:**

```bash
squeue -u $USER
```

<details>
<summary>Output</summary>
<pre>
JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
8249780 interacti   fastqc satheesh  R       0:01      1 nova21-1
</pre>
</details>

**Check logs**

```bash
ls -lh logs/
cat logs/fastqc_*.out
cat logs/fastqc_*.err
```

In this case, the fastqc*.out file is empty. This is because the output of the fastqc command is redirected to the log file. The fastqc*.err file contains the error messages, particularly the loading of the modules.

**Check efficiency**

```bash
seff 8249780
```

`seff` is a useful tool to check the efficiency of a job. It shows the actual time the job spent using the CPU and the percentage of the requested CPU time that was actually used.

<pre>
Job ID: 8249780
Cluster: nova
User/Group: satheesh/domain users
State: COMPLETED (exit code 0)
Nodes: 1
Cores per node: 10
CPU Utilized: 00:01:59
CPU Efficiency: 59.50% of 00:03:20 core-walltime
Job Wall-clock time: 00:00:20
Memory Utilized: 3.27 GB
Memory Efficiency: 40.83% of 8.00 GB (8.00 GB/node)
</pre>

**Explanation of efficiency metrics**

- **CPU Utilized**: The actual time the job spent using the CPU. In this case, the job used the CPU for 1 minute and 59 seconds.
- **CPU Efficiency**: The percentage of the requested CPU time that was actually used. Here, the job used 59.50% of the 3 minutes and 20 seconds of CPU time it requested.
- **Job Wall-clock time**: The total time the job took to complete, from start to finish. This includes time spent waiting for resources, loading data, and running the actual computation.
- **Memory Utilized**: The amount of memory the job actually used. In this case, the job used 3.27 GB of memory.
- **Memory Efficiency**: The percentage of the requested memory that was actually used. Here, the job used 40.83% of the 8 GB of memory it requested.

---

## SLURM, running ARRAY jobs

Array jobs let you run the same command over many inputs (e.g., all FASTQ files) by indexing them with `SLURM_ARRAY_TASK_ID`. SLURM schedules each index as its own task.

### Example: FastQC over all files in 01_data/ using an array

Create `00_scripts/07_fastqc_array.slurm`:

```bash
#!/usr/bin/env bash

# ===== SLURM directives =====
#SBATCH --job-name=fastqc_array
#SBATCH --account=short_term
#SBATCH --partition=interactive
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
# Use master job ID (%A) and array index (%a) for per-task logs
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err
#SBATCH --array=0-9

set -euo pipefail

# Always start in the submission directory for predictable paths
cd "$SLURM_SUBMIT_DIR"

# Output directory 
OUTPUT_DIR=02g_fastqc_slurm_array

# Ensure output directories exist
mkdir -p logs $OUTPUT_DIR

# Optional: load modules needed by the job
module load fastqc || true

# Build the file list. The array index selects which file this task processes.
FILES=(01_data/*.fastq.gz)
TARGET="${FILES[$SLURM_ARRAY_TASK_ID]}"

# Derive a clean basename for naming logs and outputs (beginner-friendly)
BASENAME=$(basename "$TARGET" .fastq.gz)        # e.g., bio_sample_01_R1

fastqc "$TARGET" -o 02g_fastqc_slurm_array/ \
  > "logs/fastqc_slurm_array_${BASENAME}.log" 2>&1
```

### How it works

- `--array=0-9` launches 10 tasks with `SLURM_ARRAY_TASK_ID` set to 0..9.
- Inside the script, `FILES=(01_data/*.fastq.gz)` builds the list of inputs; each task picks `FILES[$SLURM_ARRAY_TASK_ID]`.
- `--cpus-per-task=1` and `--mem=2G` are per-task requests. With arrays, parallelism comes from many tasks; keep per-task CPU/memory modest.
- Log patterns `%A` (master job ID) and `%a` (array index) help separate per-task stdout/stderr.

Tips:
- If your files can be very large, increase `--time` and `--mem` per task accordingly.
- Avoid combining GNU Parallel with large arrays unless you adjust `--cpus-per-task` and the tool’s `-j/--threads` to avoid oversubscription.

Submit for all files in `01_data/`:

```bash
sbatch 00_scripts/07_fastqc_array.slurm
```

**Check the status of the job:**

```bash
squeue -u $USER
```

<details>
<summary>Output</summary>
<pre>
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
         8250375_1 interacti fastqc_a satheesh  R       0:01      1 nova21-1
         8250375_2 interacti fastqc_a satheesh  R       0:01      1 nova21-1
         8250375_3 interacti fastqc_a satheesh  R       0:01      1 nova21-1
         8250375_4 interacti fastqc_a satheesh  R       0:01      1 nova21-1
         8250375_5 interacti fastqc_a satheesh  R       0:01      1 nova21-1
         8250375_6 interacti fastqc_a satheesh  R       0:01      1 nova21-1
         8250375_7 interacti fastqc_a satheesh  R       0:01      1 nova21-1
         8250375_8 interacti fastqc_a satheesh  R       0:01      1 nova21-1
         8250375_9 interacti fastqc_a satheesh  R       0:01      1 nova21-1
         8250375_0 interacti fastqc_a satheesh  R       0:02      1 nova21-1
</pre>
</details>

**Explanation of the output**

JOBID: 8250375_0, 8250375_2, …, 8250375_9
8250375 is the master job ID; the suffix _ is the array task index (0–9). Each line is one array task.

**Alternative:Count files and submit a matching array**

```bash
# Count files and submit a matching array
N=$(ls 01_data/*.fastq.gz | wc -l)
sbatch --array=0-$((N-1)) 00_scripts/07_fastqc_array.slurm

# Alternatively, if you know there are 10 files (0..9):
# sbatch --array=0-9 00_scripts/07_fastqc_array.slurm
```

**seff the job**

```bash
seff 8250375_0
```

<details>
<summary>Output</summary>
<pre>
Job ID: 8250376
Array Job ID: 8250375_0
Cluster: nova
User/Group: satheesh/domain users
State: COMPLETED (exit code 0)
Nodes: 1
Cores per node: 2
CPU Utilized: 00:00:10
CPU Efficiency: 50.00% of 00:00:20 core-walltime
Job Wall-clock time: 00:00:10
Memory Utilized: 302.76 MB
Memory Efficiency: 14.78% of 2.00 GB (2.00 GB/node)
</pre>
</details>

**sacct the job**

```bash
sacct -j 8250375 --format=JobID,JobName%20,State,Elapsed,MaxRSS,AllocCPUS,CPUTime,ExitCode
```

- `sacct`: SLURM's accounting command. It reports job and step history (finished and, depending on site config, running jobs) with detailed fields like state, elapsed wall time, peak memory (MaxRSS), allocated CPUs, and CPUTime. For arrays, pass the parent ID (e.g., `8250375`) to see all indices, or a specific one like `8250375_0`.
- `--format`: Format the output to show only the fields we care about. `%20` means 20 characters wide.
- `JobID`: The job ID.
- `JobName`: The job name.
- `State`: The state of the job. `COMPLETED` means the job finished successfully.
- `Elapsed`: The elapsed wall time.
- `MaxRSS`: The peak memory usage.
- `AllocCPUS`: The number of allocated CPUs.
- `CPUTime`: The CPU time used.
- `ExitCode`: The exit code of the job.

<details>
<summary>Output</summary>
<pre>
JobID                     JobName      State    Elapsed     MaxRSS  AllocCPUS    CPUTime ExitCode
------------ -------------------- ---------- ---------- ---------- ---------- ---------- --------
8250375_0            fastqc_array  COMPLETED   00:00:10                     2   00:00:20      0:0
8250375_0.b+                batch  COMPLETED   00:00:10    310024K          2   00:00:20      0:0
8250375_0.e+               extern  COMPLETED   00:00:10                     2   00:00:20      0:0
8250375_1            fastqc_array  COMPLETED   00:00:09                     2   00:00:18      0:0
8250375_1.b+                batch  COMPLETED   00:00:09    320032K          2   00:00:18      0:0
8250375_1.e+               extern  COMPLETED   00:00:09                     2   00:00:18      0:0
8250375_2            fastqc_array  COMPLETED   00:00:17                     2   00:00:34      0:0
8250375_2.b+                batch  COMPLETED   00:00:17    302488K          2   00:00:34      0:0
8250375_2.e+               extern  COMPLETED   00:00:17                     2   00:00:34      0:0
8250375_3            fastqc_array  COMPLETED   00:00:17                     2   00:00:34      0:0
8250375_3.b+                batch  COMPLETED   00:00:17    290540K          2   00:00:34      0:0
8250375_3.e+               extern  COMPLETED   00:00:17                     2   00:00:34      0:0
8250375_4            fastqc_array  COMPLETED   00:00:09                     2   00:00:18      0:0
8250375_4.b+                batch  COMPLETED   00:00:09    292888K          2   00:00:18      0:0
8250375_4.e+               extern  COMPLETED   00:00:09                     2   00:00:18      0:0
8250375_5            fastqc_array  COMPLETED   00:00:09                     2   00:00:18      0:0
8250375_5.b+                batch  COMPLETED   00:00:09    285000K          2   00:00:18      0:0
8250375_5.e+               extern  COMPLETED   00:00:09                     2   00:00:18      0:0
8250375_6            fastqc_array  COMPLETED   00:00:09                     2   00:00:18      0:0
8250375_6.b+                batch  COMPLETED   00:00:09    335176K          2   00:00:18      0:0
8250375_6.e+               extern  COMPLETED   00:00:09                     2   00:00:18      0:0
8250375_7            fastqc_array  COMPLETED   00:00:09                     2   00:00:18      0:0
8250375_7.b+                batch  COMPLETED   00:00:09    333360K          2   00:00:18      0:0
8250375_7.e+               extern  COMPLETED   00:00:09                     2   00:00:18      0:0
8250375_8            fastqc_array  COMPLETED   00:00:08                     2   00:00:16      0:0
8250375_8.b+                batch  COMPLETED   00:00:08    308852K          2   00:00:16      0:0
8250375_8.e+               extern  COMPLETED   00:00:08                     2   00:00:16      0:0
8250375_9            fastqc_array  COMPLETED   00:00:13                     2   00:00:26      0:0
8250375_9.b+                batch  COMPLETED   00:00:13    294728K          2   00:00:26      0:0
8250375_9.e+               extern  COMPLETED   00:00:13                     2   00:00:26      0:0
</pre>
</details>

- `8250375_0` → your array task with index 0.
- `8250375_0.bat+` (batch) → the batch step where your commands ran.
- `8250375_0.ext+` (extern) → the extern step, which tracks resource usage tied to the allocation itself (not your script directly).
- `8250375_1` → the array task with index 1, and so on.

So each array task has a main job entry, plus `.batch` and `.extern` sub-entries.

**More Reading**

<details>
<summary><strong>GNU Parallel vs SLURM Array</strong></summary>

- What they do
  - GNU Parallel: run many commands concurrently inside a single job allocation.
  - SLURM Array: launch many tasks (one per input) as separate scheduled tasks.

- When to use which
  - GNU Parallel
    - Best when you already have one allocation (interactive srun or one batch job) and want to fan out work within it.
    - Simple to cap concurrency and share memory/CPUs among tasks on one node.
  - SLURM Array
    - Best when you want per-input scheduling, isolation, and accounting — and the ability to scale across nodes.
    - Easy to retry only failed indices.

- Resource accounting and debugging
  - GNU Parallel
    - One job’s stdout/stderr unless you manually split logs per file.
    - One seff summary for the whole job; per-file timing via your own logs.
  - SLURM Array
    - Per-task stdout/stderr and per-task seff/sacct.
    - Clear which inputs failed or were slow.

- Failure isolation
  - GNU Parallel: a failing command doesn’t necessarily stop the whole job; handle exit codes yourself.
  - SLURM Array: failures are isolated to their indices; other tasks continue.

- Queue behavior and limits
  - GNU Parallel: queue once, then manage parallelism internally on the node you obtained.
  - SLURM Array: each task queues separately; site policies may cap concurrent array tasks.

- Avoid oversubscription
  - GNU Parallel inside SLURM: align -j with CPUs you requested.
    ```bash
    parallel -j "$SLURM_CPUS_PER_TASK" \
      'fastqc {1} -o 02h_fastqc_parallel/ > logs/02h_fastqc_parallel_{1/.}.log 2>&1' \
      ::: 01_data/*.fastq.gz
    ```
  - SLURM Array: keep per-task CPU/memory modest (e.g., --cpus-per-task=1–2, --mem=1–4G) and let SLURM scale via many tasks.
    ```bash
    N=$(ls 01_data/*.fastq.gz | wc -l)
    sbatch --array=0-$((N-1)) 00_scripts/07_fastqc_array.slurm
    ```

- Rules of thumb
  - Small dataset, one node available now → GNU Parallel for quick turnaround.
  - Many files, want per-input tracking/retry, or need to scale across nodes → SLURM Array.
  - Always align concurrency with resources to avoid oversubscribing CPUs/memory.

</details>