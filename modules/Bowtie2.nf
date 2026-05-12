/*
 * Using Bowtie2 as an alternative read aligner
 */

 process alignReadsBowtie2 {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }

    container 'staphb/bowtie2:2.5.4'
    
    // Add a tag to identify the process
    tag "$sample_id"

    input:
    tuple val(sample_id), path(reads)   // reads is a tuple of paths for paired-end reads
    path requiredIndexFiles

    output:
    tuple val(sample_id), file("${sample_id}.sam")

    script:
    """
    INDEX=\$(find -L ./ -name "*.bt2" | sed 's/\\.[0-9]*\\.bt2\$//' | sed 's/\\.rev//' | sort -u | head -1)
   
    bowtie2 -x \$INDEX -1 ${reads[0]} -2 ${reads[1]} -S ${sample_id}.sam

    bowtie2 \
    -x \$INDEX \
    -1 ${reads[0]} \
    -2 ${reads[1]} \
    --rg-id ${sample_id} \
    --rg SM:${sample_id} \
    --rg LB:lib1 \
    --rg PL:ILLUMINA \
    -S ${sample_id}.sam
    """
    }

process createBAM {
    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }
    container 'variantvalidator/indexgenome:1.1.0'

    tag "$samFile"

    input:
    tuple val(sample_id), path(samFile)   // reads is a tuple of paths for paired-end reads

    output:
    tuple val(sample_id), file("${samFile.baseName}.bam")

    script:
    """
    echo "Converting SAM to BAM"

    samtools view -bS ${samFile} > ${sample_id}.bam

    echo "Conversion Complete"

    """
}