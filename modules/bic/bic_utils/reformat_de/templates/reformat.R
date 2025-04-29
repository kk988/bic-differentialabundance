#!/usr/bin/env Rscript

# It will take in the RDS file from the DE results and the gene map file
# as well as the DE results file and output a new DE results file with
# the gene symbol and mean counts added. It will also output a versions
# file with the versions of the tools used to create the new DE results
# file. The new DE results file will contain the following columns:
# GeneID, GeneSymbol, log2FoldChange, meancounts(per condition), lfcSE, pvalue, padj

# read rds, de_results (tsv), filtered_de (tsv), and gene_map (tsv)
rds <- readRDS('$rdata')
de <- read.table('$de_results', header=TRUE, sep="\t", row.names=0) # GeneID baseMean log2FoldChange lfcSE pvalue padj
filtered_de <- read.table('$filtered_de', header=TRUE, sep="\t", row.names=0)
gene_map <- read.table('$gene_map', header=TRUE, sep="\t", row.names=0) # GeneID, GeneSymbol


# meta.reference, meta.target, meta.variable
baseMeanPerLvl <- sapply( c('$meta.target', '$meta.reference'), function(lvl) rowMeans( DESeq2::counts(z,normalized=TRUE)[,z[['$meta.variable']] == lvl] ) )
new_de <- merge(de, gene_map, by="GeneID", all.x=TRUE) %>%
    merge ( baseMeanPerLvl, by.x="GeneID", by.y="row.names", all.x=TRUE ) %>%
    select( -baseMean )

#output files
new_de_filename = gsub("results.tsv", "de_results.tsv","$de_results")
new_filtered_de_filename = gsub("results_filtered.tsv", "de_results_filtered.tsv","$filtered_de")

# write
write.table(new_de, file=new_de_filename, sep="\t", row.names=FALSE, quote=FALSE)

# filter new_de by gene ids in filtered_de
filtered_de <- new_de %>%
    filter(GeneID %in% filtered_de$GeneID) %>%
    select(GeneID, GeneSymbol, log2FoldChange, baseMeanPerLvl, lfcSE, pvalue, padj)
write.table(filtered_de, file=new_filtered_de_filename, sep="\t", row.names=FALSE, quote=FALSE)


