#!/bin/bash

submit_job() {
    local count_file=$1
    local tissue_name=$2
    local job_name="differential_analysis_${tissue_name}"
    local output_file="${job_name}.out"
    local error_file="${job_name}.err"

    sbatch <<EOT
#!/bin/bash
#SBATCH --job-name=${job_name}
#SBATCH --output=${output_file}
#SBATCH --error=${error_file}
#SBATCH --partition=your_partition
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=guzmanwg@kaust.edu.sa

module load R

Rscript differential_analysis.R "$count_file" "$tissue_name"
EOT
}

for tissue_dir in /ibex/user/guzmanwg/ENTEX_bamfiles/TEtranscript/*; do
    tissue_name=$(basename "$tissue_dir")

    for count_file in "$tissue_dir"/*/*.cntTable; do
        submit_job "$count_file" "$tissue_name"
    done
done

