#!/bin/bash
#SBATCH --constraint=cascadelake
#SBATCH --time=2-23:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH --job-name=mapped_reads_count
#SBATCH --mem=16G
#SBATCH --output=mapped_reads_count.out
#SBATCH --error=mapped_reads_count.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=guzmanwg@kaust.edu.sa

# Main directory where the folders are located
main_directory="/ibex/user/guzmanwg/ENTEX_bamfiles/TEtranscript"

# Output file name
output_file="$main_directory/mapped_reads_count.txt"

# Create header for the output file
echo -e "BAM_File\tMapped_Reads_Count" > "$output_file"

# Iterate through each folder in the main directory
for folder in "$main_directory"/*/; do
    echo "Processing folder: $folder"
    # Get the name of the folder
    folder_name=$(basename "$folder")
    # Iterate through each BAM file in the folder
    for bam_file in "$folder"*.bam; do
        # Get the name of the BAM file
        bam_name=$(basename "$bam_file")
        # Count the mapped reads using samtools
        mapped_reads=$(samtools view -c -f 1 -F 12 "$bam_file")
        # Convert the number of mapped reads to millions
        mapped_reads_millions=$(echo "scale=2; $mapped_reads / 1000000" | bc)
        # Write the results to the output file
        echo -e "${folder_name}/${bam_name}\t${mapped_reads_millions}" >> "$output_file"
    done
done