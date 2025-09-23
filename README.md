## Workshop 2 - Introduction to Pipeline Development with Bash - September 23rd, 2025 (1pm-5pm)

Workshop 2 is an introductory course into pipeline development within a bash environment. Pipelines are a fundamental part of many development workflows, allowing for efficient automation and chaining of commands. Users will learn what is a pipeline, basic scripting including the use of variables and loops, using GNU Parallel for parallelization, and a basic introduction into Nextflow. This course will lead perfectly into workshop three. 

## Instructors
- Viswanathan Satheesh
- Rick Masonbrink
- Sharu Paul Sharma

## Quick start

- VS Code Server on Nova OnDemand through a browser: `https://nova-ondemand.its.iastate.edu/`

  ```
  Account: short_term
  Partition: interactive
  Number of hour: 4
  Number of Tasks per node: 10
  Memory Required: 8G
  ```

- File -> Open Folder -> `/work/short_term/<your username>/` - create the directory if it does not exist:

  ```bash
  cd /work/short_term/
  mkdir -p $USER
  ```

- Then do File -> Open Folder -> `/work/short_term/<your username>/`

- Clone git repository:

  ```bash
  git clone https://github.com/ISUgenomics/isu-bash-pipeline-2025.git
  ```

## Copy data files and scripts

```bash
cp -a /work/short_term/workshop2_bash/01_data .
```
- `a` = archive mode, which is shorthand for:  
      -p -> preserve mode, ownership, and timestamps  
      -R -> recursive copy (entire folder tree)  
      plus symbolic links, devices, etc.  

## Terminal

- Through Nova OnDemand
- Get a terminal

## Naming Conventions

- **Common styles (for reference)**
  - `camelCase` — first word lowercase, subsequent words capitalized; avoid in Bash.
  - `PascalCase` — every word capitalized; avoid in Bash.
  - `snake_case` — words separated by underscores; good for Bash identifiers and filenames.
  - `kebab-case` — words separated by hyphens; good for filenames/directories, not valid for variables.
  - `dot.separated` — words separated by periods; reserve dot for file extensions (e.g., `.sh`, `.log`).
  - `UPPER_SNAKE_CASE` — underscores with all caps; common for constants and environment variables.

- **Workshop standard (what we will use)**
  - Files and directories: numbered + `snake_case` (e.g., `01_data/`, `00_scripts/`). No spaces.
  - Shell scripts: numbered + `snake_case` + `.sh` (e.g., `01_fastqc.sh`, `02_fastqc_loop.sh`).
  - Log files: 
  - Avoid additional dots in names (use only for extensions). Avoid spaces and special characters.

- **Shell script identifiers**
  - Variables (default): `lower_snake_case` (e.g., `sample_id`).
  - Constants/env or exported parameters: `UPPER_SNAKE_CASE` (e.g., `INPUT_DIR`, `LOG_DIR`).
  
  ## Resources

  - [Shell Scripting - Rules for Naming Variable Name](https://www.geeksforgeeks.org/shell-scripting-rules-for-naming-variable-name/)
