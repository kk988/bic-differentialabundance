process PREFORMAT_INPUT {
    label 'process_single'

    conda "conda-forge::coreutils=9.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-base:4.2.1' :
        'biocontainers/r-base:4.2.1' }"

    input:
    tuple val(meta), path(input_file)
    tuple val(meta2), path(comparisons_file)
    tuple val(meta3), path(counts_file)

    output:
    tuple val(meta), path('updated_input.csv'), emit: updated_input
    tuple val(meta3), path('updated_counts.tsv'), emit: updated_counts
    path "versions.yml" , emit: versions

    script:
    template 'preformat_input.R'

}
