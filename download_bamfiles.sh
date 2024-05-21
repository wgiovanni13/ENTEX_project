#!/bin/sh

#SBATCH --time=2-23:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=batch
#SBATCH --job-name=download_bamfiles
#SBATCH --mem=16G
#SBATCH --output=log_slurm.txt
#SBATCH --mail-type=ALL
#SBATCH --mail-user=guzmanwg@kaust.edu.sa

cd /ibex/user/guzmanwg/ENTEX_bamfiles/TEtranscript || exit 1

download_bam() {
	folder="$1"
	links="$folder/enlaces.txt"
	if [[ -f "$links" ]]; then 

		cat "$links" | parallel -j4 wget -P "$folder"
	fi 
}


for folder in */; do
	if [ -d "$folder" ]; then 
		download_bam "$folder" &
	fi
done

wait

echo "bam file download completed"
