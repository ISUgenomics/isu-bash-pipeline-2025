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

##### Add the command to a script and save it as `fastqc_01.sh` in `00_scripts` directory.

```bash
cat 00_scripts/fastqc_01.sh
```

<details>
<summary>Output</summary>
<pre>
mkdir -p 02_fastqc
fastqc 01_data/bio_sample_01_R1.fastq.gz -o 02_fastqc/
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
