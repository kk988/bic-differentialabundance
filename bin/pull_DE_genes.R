#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(openxlsx))
suppressPackageStartupMessages(library(tidyverse))

# de results header:
# gene_id	baseMean	log2FoldChange	lfcSE	pvalue	padj

# gene list header:
# GeneID    GeneSymbol

args <- commandArgs(trailingOnly = TRUE)
print(args)

de_res <- as_tibble(read.delim(args[1], sep = "\t", header = TRUE))
gene_map <- as_tibble(read.delim(args[2], sep = "\t", header = TRUE))
gene_file <- args[3]

gene_list <- de_res %>% 
            filter(padj < 0.05) %>%
            slice_max(abs(log2FoldChange), n = 50, with_ties = FALSE) %>%
            pull(gene_id)

# change to gene Symbols
genes <- gene_map %>% filter( GeneID %in% gene_list ) %>% pull(GeneSymbol)

write(genes, file = gene_file)