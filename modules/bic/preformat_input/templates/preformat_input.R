#!/usr/bin/env Rscript

opt <- list(
    input_file = '$input_file',
    contrasts_file = '$comparisons_file',
    counts_file = '$counts_file',
    exclude_value = '_EXCLUDE_'
) 

input <- read.csv(opt\$input_file, header = TRUE, check.names = FALSE)
contrasts <- read.csv(opt\$contrasts_file, header = TRUE, check.names = FALSE)

# get variable names
contrast_cols <- unique(contrasts\$variable)

# if there is more than one contrast column, error, we don't know how to handle that
if (length(contrast_cols) > 1) {
  stop("Please only include one contrast column per contrast file.")
}

# see if there are any _EXCLUDE_ in the contrast column
exclude <- opt\$exclude_value == input[contrast_cols]

updated_input <- input[!exclude, ]
write.csv(updated_input, "updated_input.csv", quote = FALSE, row.names = FALSE)

# now we remove excluded samples from raw counts
samples_to_exclude <- unique(input[exclude, ]\$sample)
counts <- read.delim(opt\$counts_file,
                    sep = "\t",
                    header = TRUE,
                    check.names = FALSE)

updated_counts <- counts[, !colnames(counts) %in% samples_to_exclude]
write.table(updated_counts,
            "updated_counts.tsv",
            quote = FALSE,
            row.names = FALSE,
            sep = "\t")

################################################
################################################
## R SESSION INFO                             ##
################################################
################################################

sink("R_sessionInfo.log")
print(sessionInfo())
sink()

################################################
################################################
## VERSIONS FILE                              ##
################################################
################################################

r_version <- strsplit(version[['version.string']], ' ')[[1]][3]

writeLines(
    c(
        '"${task.process}":',
        paste("    r-base:", r_version)
    ),
"versions.yml")

################################################
################################################
################################################
################################################
