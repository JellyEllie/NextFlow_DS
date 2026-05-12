/*
 * Using FreeBayes as an alternative variant caller
 */

process freebayesCaller {
    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }
    container 'staphb/freebayes:1.3.10'

    tag "$bamFile"

    input:
    tuple val(sample_id), file(bamFile)
    path indexFiles

    output:
    tuple val(sample_id), file("*.vcf")

    script:
    """
    echo "Running freebayesCaller for Sample: ${bamFile}"
    echo "Genome File: \${genomeFasta}"

    outputVcf="\$(basename ${bamFile} _sorted_dedup_recalibrated.bam).vcf"


    freebayes \
    -f \${genomeFasta} \
    ${bamfile} \
    > "\${outputVcf}"

    echo "Variant Calling for Sample: ${sample_id} Complete"
    """
}

