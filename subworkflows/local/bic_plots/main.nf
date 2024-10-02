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
include { PC_LOAD } from '../../../modules/local/rnaseq_analysis_modules/pc_load/main'
include { CREATE_SAMPLE_KEY } from '../../../modules/local/bic_utils/create_sample_key'

take:
ch_input // channel [meta, input.csv]  used in creating sample key
ch_in_raw // channel [meta, counts] used in creating gene map, possibly some modules

//ch_all_out // channel [meta, samples, gtf, counts]


// vst
// normalized counts
// de results folder?

// need to make sample key from input.csv
CREATE_SAMPLE_KEY(ch_input)
ch_sample_key = CREATE_SAMPLE_KEY.out.sample_key

// need to make gene map from counts file
CREATE_GENE_MAP(ch_in_raw)
ch_gene_map = CREATE_GENE_MAP.out.gene_map

// Sample to sample distance
SAMPLE_TO_SAMPLE_DISTANCE(ch_vst, ch_sample_key)


// DE heatmaps
// PC loadings
