process CREATE_GENE_MAP {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::coreutils=9.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"

    input:
    tuple val(meta), path(merged_counts)

    output:
    path 'gene_map.tsv' , emit: gene_map
    path "versions.yml" , emit: versions

    script:
    """
    #!/bin/bash

    # Extract the column indices for the headers
    col1=$(head -1 "${merged_counts}" | tr ',' '\n' | nl -v 0 | grep -w "GeneID" | awk '{print $1}')
    col2=$(head -1 "${merged_counts}" | tr ',' '\n' | nl -v 0 | grep -w "GeneSymbol" | awk '{print $1}')

    # Extract the sample key
    cut -d, -f$col1,$col2 "${merged_counts}" > gene_map.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(echo \$(bash --version | grep -Eo 'version [[:alnum:].]+' | sed 's/version //'))
    END_VERSIONS
    """
}
