// This is a script that will use R to add a column to the DE results files
// with gene symbol based on gene id. It will also provide mean count for
// each condition in the results file.

process REFORMAT_DE {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-deseq2:1.34.0--r41hc247a5b_3' :
        'biocontainers/bioconductor-deseq2:1.34.0--r41hc247a5b_3' }"

    input:
    tuple val(meta), path(de_results), path(filtered_de), path(rdata) //rdata and de from DESEQ, filtered_de from FILTER_DIFFTABLE
    path gene_map

    output:
    tuple val(meta), path("*de_results.tsv"), emit: reformatted_de
    tuple val(meta), path("*de_results_filtered.tsv"), emit: filtered_reformatted_de
    path "versions.yml" , emit: versions

    script:
    template 'reformat_de.R'

}
