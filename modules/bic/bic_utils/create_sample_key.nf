process CREATE_SAMPLE_KEY {
    tag "$variable_meta.id"
    label 'process_single'

    conda "conda-forge::coreutils=9.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"

    input:
    val(variable_meta)
    tuple val(meta), path(input_file)

    output:
    tuple val(variable_meta), path('*_sample_key.tsv') , emit: sample_key
    path "versions.yml"                               , emit: versions

    script:
    """

    # Extract the column indices for the headers
    col1=\$(head -1 "${input_file}" | tr ',' '\\n' | nl | grep -w "sample" | awk '{print \$1}')
    col2=\$(head -1 "${input_file}" | tr ',' '\\n' | nl | grep -w "${variable_meta.id}" | awk '{print \$1}')

    # Check if columns were found
    if [[ -z "\$col1" || -z "\$col2" ]]; then
        echo "Error: Required headers 'sample' or '${variable_meta.id}' not found in the input file." >&2
        exit 1
    fi

    # Extract the sample key
    cut -d, -f\$col1,\$col2 <(tail -n +2 "${input_file}")  | tr ',' '\\t' | sort | uniq > ${variable_meta.id}_sample_key.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(bash --version | head -n 1 | awk '{print \$4}')
    END_VERSIONS
    """
}
