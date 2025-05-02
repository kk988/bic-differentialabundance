# cBio-MSKCC/bic-differentialabundance: Changelog

## v1.5.0_bic_2.0.0

### `Added`

- Module to reformat DESeq2 output files to include GeneSymbol, mean counts per gene per condition. Old output files are not being published to final directory.

### `Changed`
- Moved running BIC's create gene map module to main differentialabundance workflow.

### `Deprecated`
- Old DESeq2 output files (tsv files from DESEQ2_DIFFERENTIAL and FILTER_DIFFTABLE) are not being published. Instead the new reformatted output files are will be published.

## v1.5.0_bic_1.0.0

Initial release of this pipeline. This includes nf-core/differentialabundance version 1.5.0 with additional items added specifically for BIC's pipeline.
