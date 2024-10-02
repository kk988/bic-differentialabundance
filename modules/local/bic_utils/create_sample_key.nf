process CREATE_SAMPLE_KEY {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::coreutils=9.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"

    input:
    tuple val(meta), path(input_file)

    output:
    path 'sample_key.tsv' , emit: sample_key
    path "versions.yml" , emit: versions

    script:
    """
    #!/bin/bash

    # Extract the column indices for the headers
    col1=$(head -1 "${input_file}" | tr ',' '\n' | nl -v 0 | grep -w "sample" | awk '{print $1}')
    col2=$(head -1 "${input_file}" | tr ',' '\n' | nl -v 0 | grep -w "condition" | awk '{print $1}')

    # Extract the sample key
    cut -d, -f$col1,$col2 "${input_file}" > sample_key.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(echo \$(bash --version | grep -Eo 'version [[:alnum:].]+' | sed 's/version //'))
    END_VERSIONS
    """
}
