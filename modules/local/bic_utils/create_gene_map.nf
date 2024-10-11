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

    # Extract the column indices for the headers
    col1=\$(head -1 "${merged_counts}" | tr '\\t' '\\n' | nl | grep -w "GeneID" | head -n 1 | awk '{print \$1}')
    col2=\$(head -1 "${merged_counts}" | tr '\\t' '\\n' | nl | grep -w "GeneSymbol" | awk '{print \$1}')

    # Check if columns were found
    if [[ -z "\$col1" || -z "\$col2" ]]; then
        echo "Error: Required headers 'GeneID' or 'GeneSymbol' not found in the input file." >&2
        exit 1
    fi

    # Extract the sample key
    cut -f\$col1,\$col2 "${merged_counts}" > gene_map.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(bash --version | head -n 1 | awk '{print \$4}')
    END_VERSIONS
    """
}
