process HEATMAP {
    tag "${meta2.reference}_${meta2.target}"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        '/juno/bic/depot/singularity/bic_rnaseq_modules/tag/2.0.2/bic_rnaseq_modules_2.0.2.simg' :
        '/juno/bic/depot/singularity/bic_rnaseq_modules/tag/2.0.2/bic_rnaseq_modules_2.0.2.simg' }"

    input:
    tuple val(meta), path(norm)        // normalized counts
    tuple val(meta2), path(de_results), val(contrast_meta), path(sample_key) // DE results file 
    path(gene_map)                     // gene map (gene id to gene name)
    // conditions
    
    output:
    path '*/png/*.png'  , emit: heatmaps //heatmaps
    path "versions.yml" , emit: versions

    script:
    def args = task.ext.args ?: ''
    def out_file = "${meta2.id}/png/heatmap.png"
    def title = "${meta2.target} vs ${meta2.reference} DE Heatmap"

    """
    mkdir -p \$(dirname ${out_file})

    pull_DE_genes.R ${de_results} ${gene_map} gene_list.txt

    Rscript /rnaseq_analysis_modules/make_de_heatmap.R \
    --norm_counts_file ${norm} \
    --key_file ${sample_key} \
    --annotate_samples \
    --title "${title}" \
    --conditions ${meta2.reference},${meta2.target} \
    --gene_map ${gene_map} \
    --out_file ${out_file} \
    --file_type png \
    --gene_file gene_list.txt \
    ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        rnaseq_analysis_modules: \$(cat /rnaseq_analysis_modules/VERSION.txt)
    END_VERSIONS
    """

}
