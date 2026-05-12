/*
 * Run trimming using fastp on fastq files
 */

 process FASTP {

    label 'process_single'

    container 'staphb/fastp:1.1.0'
    
    // Add a tag to identify the process
    tag "$sample_id"

    // Specify the output directory for the FASTP results
    publishDir("$params.outdir/FASTP", mode: "copy")

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id),
          path("fastp_${sample_id}_*.fastq.gz"),
          path("${sample_id}_fastp.html"),
          path("${sample_id}_fastp.json")

    script:
    """
    echo "Running FASTP"
    mkdir -p fastp_${sample_id}
    
    fastp -i ${reads[0]} -I ${reads[1]} \
      -o fastp_${sample_id}_R1.fastq.gz \
      -O fastp_${sample_id}_R2.fastq.gz \
      -h ${sample_id}_fastp.html \
      -j ${sample_id}_fastp.json
    
    echo "FASTP Complete"
    """
 }