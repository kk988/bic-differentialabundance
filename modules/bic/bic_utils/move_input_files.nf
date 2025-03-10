process MOVE_INPUT_FILES {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::coreutils=9.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"

    input:
    tuple val(meta), path(input_file)
    tuple val(meta2), path(comparisons_file)
    tuple val(meta3), path(counts_file)

    output:
    path('*_input.csv')
    path('*_contrasts.csv')
    path('*_counts.tsv')
    path "versions.yml" , emit: versions

    script:
    """
    cp ${input_file} ${meta.id}_input.csv
    cp ${comparisons_file} ${meta.id}_contrasts.csv
    cp ${counts_file} ${meta.id}_counts.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(bash --version | head -n 1 | awk '{print \$4}')
    END_VERSIONS
    """
}
