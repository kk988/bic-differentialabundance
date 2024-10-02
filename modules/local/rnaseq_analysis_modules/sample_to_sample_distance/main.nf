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
    path 'sample_to_sample_distance.pdf' , emit: sample_dist_pdf
    path "versions.yml" , emit: versions

    script:
    def args = task.ext.args ?: ''
    def out_file = "sample_to_sample_distance.pdf"
    """
    Rscript /rnaseq_analysis_modules/sample_to_sample_distance.R \
    --vsd ${vst} \
    --sample_key ${sample_key} \
    --annotate_samples \
    --out_file ${out_file} \
    ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        rnaseq_analysis_modules: \$(echo /rnaseq_analysis_modules/VERSION.txt)
    END_VERSIONS
    """

}
