process PC_LOADING {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        '/juno/bic/work/kristakaz/nf-diff/singularity_cache/bic_rnaseq_modules_2.0.2.simg' :
        '/juno/bic/work/kristakaz/nf-diff/singularity_cache/bic_rnaseq_modules_2.0.2.simg' }"

    input:
    tuple val(meta), path(vst)
    path(sample_key)
    path(gene_map)

    output:
    path '*.pdf' , emit: plot
    path "versions.yml" , emit: versions

    script:
    def args = task.ext.args ?: ''
    def out_file = "pc_loading.pdf"
    """
    Rscript /rnaseq_analysis_modules/make_pca_loading_plot.R \
    --vsd ${vst} \
    --key_file ${sample_key} \
    --out_file ${out_file} \
    --gene_map ${gene_map} \
    ${args}

    rm Rplots.pdf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        rnaseq_analysis_modules: \$(echo /rnaseq_analysis_modules/VERSION.txt)
    END_VERSIONS
    """

}
