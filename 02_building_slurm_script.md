# Building a SLURM script (very basics)

SLURM (Simple Linux Utility for Resource Management) is the job scheduler that manages who gets to use the cluster’s compute nodes and for how long. You will log in to a head/login node to prepare your work, and then ask SLURM to run your jobs on compute nodes with the resources you request.

If you remember just one thing: you don’t run heavy work directly on the head node. You ask SLURM to run it for you on a compute node.

---

## Why do we use SLURM?

- It shares the cluster fairly among many users.
- It finds and reserves the resources you need (CPUs, memory, time).
- It tracks your job, captures logs, and reports status.

---

## Key words (plain language)

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

```bash
srun --account=short_term --partition=interactive \
     --time=00:15:00 --cpus-per-task=1 --mem=2G \
     --pty bash
```

You’ll get a shell on a compute node where you can run commands interactively. Exit with `exit` or Ctrl-D.

---

## Running a SLURM job

We are going to use the `05_fastqc_parallel_improved.sh` script as an example.

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
