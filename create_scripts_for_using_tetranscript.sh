#!/bin/bash
#SBATCH --constraint=cascadelake
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=batch
#SBATCH --job-name=generate_TEcount_scripts
#SBATCH --mem=8G
#SBATCH --output=generate_TEcount_scripts.out
#SBATCH --error=generate_TEcount_scripts.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=guzmanwg@kaust.edu.sa

main_directory="/ibex/user/guzmanwg/ENTEX_bamfiles/TEtranscript"
count_file="$main_directory/mapped_reads_count.txt"

# Read the count file
tail -n +2 "$count_file" | while IFS=$'\t' read -r bam_file mapped_reads_count; do
    bam_name=$(basename "$bam_file" .bam)
    folder=$(dirname "$bam_file")
    mkdir -p "$folder/$bam_name"
    mem_needed=$(echo "($mapped_reads_count + 10 + 0.5) / 1" | bc)
    for cpus in 16 32; do
        script_file="$folder/$bam_name/${bam_name}_TEcount_${cpus}cpu.sh"
        echo "#!/bin/bash" > "$script_file"
        echo "#SBATCH --constraint=cascadelake" >> "$script_file"
        echo "#SBATCH --time=2-23:00:00" >> "$script_file"
        echo "#SBATCH --nodes=1" >> "$script_file"
        echo "#SBATCH --ntasks=1" >> "$script_file"
        echo "#SBATCH --cpus-per-task=$cpus" >> "$script_file"
        echo "#SBATCH --partition=batch" >> "$script_file"
        echo "#SBATCH --job-name=TEcount_${bam_name}_${cpus}cpu" >> "$script_file"
        echo "#SBATCH --mem=${mem_needed}G" >> "$script_file"
        echo "#SBATCH --mail-type=FAIL" >> "$script_file"
        echo "#SBATCH --mail-user=guzmanwg@kaust.edu.sa" >> "$script_file"
        echo "" >> "$script_file"
        echo "module load singularity" >> "$script_file"
        echo "" >> "$script_file"
        echo "main_directory=\"/ibex/user/guzmanwg/ENTEX_bamfiles/TEtranscript\"" >> "$script_file"
        echo "output_folder=\"\$main_directory/$folder/$bam_name\"" >> "$script_file"
        echo "gtf_file=\"\$main_directory/gencode.v29.annotation.gtf\"" >> "$script_file"
        echo "te_file=\"\$main_directory/GRCh38_GENCODE_rmsk_TE.gtf\"" >> "$script_file"
        echo "sif_container=\"\$main_directory/tetranscripts.sif\"" >> "$script_file"
        echo "output_file=\"\$main_directory/TEcount_${cpus}cpu_results.txt\"" >> "$script_file"
        echo "" >> "$script_file"
        echo "bam=\"\$main_directory/$bam_file\"" >> "$script_file"
        echo "" >> "$script_file"
        echo "if [ -f \"\$bam\" ]; then" >> "$script_file"
        echo "    echo \"Processing file: \$bam\"" >> "$script_file"
        echo "    start_time=\$(date +%s)" >> "$script_file"
        echo "    singularity exec --bind \"\$main_directory\" \"\$sif_container\" TEcount --sortByPos --format BAM --stranded reverse --mode multi -b \"\$bam\" --GTF \"\$gtf_file\" --TE \"\$te_file\" --outputDir \"\$output_folder\"" >> "$script_file"
        echo "    end_time=\$(date +%s)" >> "$script_file"
        echo "    elapsed_time=\$((end_time - start_time))" >> "$script_file"
        echo "    echo -e \"$folder:$bam_name\t$cpus\t\$elapsed_time\" >> \"\$output_file\"" >> "$script_file"
        echo "else" >> "$script_file"
        echo "    echo \"Error: BAM file not found: \$bam\"" >> "$script_file"
        echo "fi" >> "$script_file"
        chmod +x "$script_file"
        echo "Script generated: $script_file"
        sbatch "$script_file"
    done
done
