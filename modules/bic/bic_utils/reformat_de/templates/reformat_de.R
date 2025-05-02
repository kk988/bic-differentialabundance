#!/usr/bin/env Rscript

# It will take in the RDS file from the DE results and the gene map file
# as well as the DE results file and output a new DE results file with
# the gene symbol and mean counts added. It will also output a versions
# file with the versions of the tools used to create the new DE results
# file. The new DE results file will contain the following columns:
# GeneID, GeneSymbol, log2FoldChange, meancounts(per condition), lfcSE, pvalue, padj

# read rds, de_results (tsv), filtered_de (tsv), and gene_map (tsv)
rds <- readRDS('$rdata')
de <- read.table('$de_results', header=TRUE, sep="\t") # GeneID baseMean log2FoldChange lfcSE pvalue padj
filtered_de <- read.table('$filtered_de', header=TRUE, sep="\t")
gene_map <- read.table('$gene_map', header=TRUE, sep="\t") # GeneID, GeneSymbol


# combine de results, gene symbols, and mean counts
baseMeanPerLvl <- sapply( c('$meta.target', '$meta.reference'), function(lvl) rowMeans( DESeq2::counts(rds,normalized=TRUE)[,rds[['$meta.variable']] == lvl] ) )
de_gene_map <- merge(de, gene_map, by="GeneID", all.x=TRUE)
new_de <- merge(de_gene_map, baseMeanPerLvl, by.x="GeneID", by.y="row.names", all.x=TRUE )

# rename mean counts columns
colnames(new_de)[colnames(new_de) %in% c('$meta.target', '$meta.reference')] <- c(paste0("Mean_at_cond_",'$meta.target'), paste0("Mean_at_cond_",'$meta.reference'))
# Move "GeneSymbol" to the second position and remove "baseMean"
new_de <- new_de[, c(names(new_de)[1], "GeneSymbol", setdiff(names(new_de)[-1], c("GeneSymbol", "baseMean")))]

#output files
new_de_filename = gsub("results.tsv", "de_results.tsv","$de_results")
new_filtered_de_filename = gsub("results_filtered.tsv", "de_results_filtered.tsv","$filtered_de")

# write
write.table(new_de, file=new_de_filename, sep="\t", row.names=FALSE, quote=FALSE)

# Filter rows where GeneID in new_de is in filtered_de GeneID
filtered_de <- new_de[new_de[["GeneID"]] %in% filtered_de[["GeneID"]], ]

write.table(filtered_de, file=new_filtered_de_filename, sep="\t", row.names=FALSE, quote=FALSE)



################################################
################################################
## VERSIONS FILE                              ##
################################################
################################################

r.version <- strsplit(version[['version.string']], ' ')[[1]][3]

writeLines(
    c(
        '"${task.process}":',
        paste('    r-base:', r.version)
    ),
'versions.yml')

################################################
################################################
################################################
################################################
