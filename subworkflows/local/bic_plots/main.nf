//
// Subworkflow to run bic rnaseq analysis plots
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { HEATMAP } from '../../../modules/local/rnaseq_analysis_modules/heatmap/main'
include { SAMPLE_TO_SAMPLE_DISTANCE } from '../../../modules/local/rnaseq_analysis_modules/sample_to_sample_distance/main'
include { PC_LOADING } from '../../../modules/local/rnaseq_analysis_modules/pc_loading/main'
include { CREATE_SAMPLE_KEY } from '../../../modules/local/bic_utils/create_sample_key'
include { CREATE_GENE_MAP } from '../../../modules/local/bic_utils/create_gene_map'
include { MDS_CLUSTERING } from '../../../modules/local/rnaseq_analysis_modules/mds_clustering'

workflow BIC_PLOTS {

    take:
    ch_input  // channel [meta, input.csv]  used in creating sample key
    ch_in_raw // channel [meta, counts] used in creating gene map, possibly some modules
    ch_vst    // channel [meta, vst]
    ch_norm   // channel [meta, normalized counts]
    ch_diff   // channel [meta, diff results]
    
    main:
    ch_versions = Channel.empty()

    // need to make sample key from input.csv
    CREATE_SAMPLE_KEY(ch_input)
    ch_sample_key = CREATE_SAMPLE_KEY.out.sample_key.first()
    ch_versions = ch_versions.mix(CREATE_SAMPLE_KEY.out.versions)

    // need to make gene map from counts file
    CREATE_GENE_MAP(ch_in_raw)
    ch_gene_map = CREATE_GENE_MAP.out.gene_map.first()
    ch_versions = ch_versions.mix(CREATE_GENE_MAP.out.versions)

    // Sample to sample distance
    SAMPLE_TO_SAMPLE_DISTANCE(ch_vst, ch_sample_key)
    ch_versions = ch_versions.mix(SAMPLE_TO_SAMPLE_DISTANCE.out.versions)
 
    // DE heatmaps
    HEATMAP(ch_norm, ch_diff, ch_sample_key, ch_gene_map)
    ch_versions = ch_versions.mix(HEATMAP.out.versions)

    //PC loadings
    PC_LOADING(ch_vst, ch_sample_key, ch_gene_map)
    ch_versions = ch_versions.mix(HEATMAP.out.versions)

    //MDS clustering
    MDS_CLUSTERING(ch_norm, ch_sample_key)
    ch_versions = ch_versions.mix(MDS_CLUSTERING.out.versions)

    emit:
    versions    = ch_versions

}
