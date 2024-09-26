process SAMPLE_TO_SAMPLE_DISTANCE {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-deseq2:1.34.0--r41hc247a5b_3' :
        'biocontainers/bioconductor-deseq2:1.34.0--r41hc247a5b_3' }"

    input:
    tuple val(meta), path(vst)
    path(sample_key)

    output:
    

}