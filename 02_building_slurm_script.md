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
- **Head/Login node**: Where you log in, write scripts, submit jobs. Don’t run heavy jobs here.
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

# Submit a batch script
touch example.sh   # your script
echo "#!/usr/bin/env bash" > example.sh
sbatch example.sh

# Cancel a job by its Job ID
scancel <JOBID>

# Show info about a job
scontrol show job <JOBID>
```

Tip: Use `history | grep sbatch` to find previous submissions.

---

## A minimal SLURM batch script

Create a file named `00_scripts/10_hello_slurm.sh` with the following contents. This is a tiny job that just prints some info on a compute node.

```bash
#!/usr/bin/env bash

# ===== SLURM directives (read by the scheduler) =====
#SBATCH --job-name=hello_slurm            # a short name for your job
#SBATCH --account=short_term              # account/allocation (from workshop Quick start)
#SBATCH --partition=interactive           # partition/queue (from workshop Quick start)
#SBATCH --time=00:05:00                   # max wall time (hh:mm:ss)
#SBATCH --cpus-per-task=1                 # number of CPU cores
#SBATCH --mem=1G                          # memory per node (or per CPU on some clusters)
#SBATCH --output=logs/%x_%j.out           # STDOUT (%x=job-name, %j=jobid)
#SBATCH --error=logs/%x_%j.err            # STDERR

set -euo pipefail

# Make sure the log directory exists
mkdir -p logs

# ===== Your commands run on a compute node below this line =====

echo "Hello from SLURM!"

# Show where we are running
hostname

# Show some environment information
printf "\nSLURM job info:\n"
echo "JOB_ID=$SLURM_JOB_ID"
echo "JOB_NAME=$SLURM_JOB_NAME"
echo "CPUS=$SLURM_CPUS_PER_TASK"
```

How to submit and check:

```bash
chmod +x 00_scripts/10_hello_slurm.sh
sbatch 00_scripts/10_hello_slurm.sh
squeue -u $USER            # see it pending or running

# After it finishes, check logs
ls -l logs/
cat logs/hello_slurm_*.out
cat logs/hello_slurm_*.err
```

What the SLURM options mean (simple):

- `--account` and `--partition`: pick where the job runs and which allocation it uses. For this workshop: `short_term` + `interactive`.
- `--time`: SLURM stops jobs that exceed this time. Request a little more than you expect.
- `--cpus-per-task`: how many CPU cores your program can use.
- `--mem`: how much RAM your job needs. If you request too little, your job may be killed.
- `--output` and `--error`: where standard output and error messages go.

---

## Moving from one-off commands to a SLURM script

Earlier you ran tools like `fastqc` directly or in loops. With SLURM you put those same commands into a batch script and add `#SBATCH` lines at the top to ask for resources. Example skeleton:

```bash
#!/usr/bin/env bash
#SBATCH --job-name=my_task
#SBATCH --account=short_term
#SBATCH --partition=interactive
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail
mkdir -p logs

# Load modules if needed
# module load fastqc

# Your actual work
# fastqc 01_data/bio_sample_01_R1.fastq.gz -o 02_fastqc/
```

Then submit with:

```bash
sbatch 00_scripts/my_task.sh
```

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

## Common questions

- Why is my job PENDING? Often because the partition is full or your request is too large. Check `sinfo` and consider lowering CPUs/mem/time.
- Where are my logs? In the files you set with `--output` and `--error` (we used the `logs/` directory).
- How do I stop a job? `scancel <JOBID>`.

---

## Mini exercise

1) Submit the `hello_slurm` script above. Find the Job ID with `squeue -u $USER`.
2) After it completes, open the corresponding `logs/hello_slurm_<JOBID>.out` file and read the job information it printed.
3) Change `--cpus-per-task` to 2 and resubmit. Confirm in the output that SLURM set `CPUS=2`.

That’s it—you now know what SLURM is and how to submit your first job.
