#!/usr/bin/env python3

# This code will take in BIC Mapping and make an input file for the NF pipeline
# Requirements: mapping file, access to the fastq (as fastq.gz).

# This will not make a perfect input file. The sample names in nf-rnaseq double as
# the grouping file as well.

# the sample names should only have one underscore in them

#Ex:
# samplename,fastq1,fastq2,strandedness
# ABCD_1,L1_fq1,L1_fq2,auto
# ABCD_1,L2_fq1,L2_fq2,auto
# ABCD_2,fq1,fq2,forward
# ABCD_3,fq1,fq2,forward
# ZYXX_1,fq1,fq2,reverse
# ZYXX_2,fq1,fq2,reverse
# ZYXX_3,fq1,fq2,unstranded

import argparse
import glob
import re
import sys

lane_pattern = r"_S.*_(L\d{3})_(R[12])_\d{3}.f"

def parse_args():
    parser = argparse.ArgumentParser(description='Convert BIC mapping and pairing files to input file for NF pipeline')
    parser.add_argument('-m', '--mapping', type=str, required=True, help='BIC mapping file')
    parser.add_argument('-s', '--strandedness', type=str, choices=['auto', 'forward', 'reverse', 'unstranded'], required=True, help='strandedness of the fastq')
    parser.add_argument('-k', '--key', type=str, required=False, help='key file - use if some of the samples are not being compared in DE analysis', default=None)
    parser.add_argument('-c', '--comparisons', type=str, required=False, help='comparison file - use if you want to generate contrasts for nf-diff', default=None)
    parser.add_argument('-o', '--output', type=str, required=True, help='Output file')
    parser.add_argument('--fq_pattern', type=str, required=False, help='pattern to find fq in mapping folder (default: /*_L*_R1_*.fastq.gz)', default='/*_L*_R1_*.fastq.gz')
    return parser.parse_args()

def generate_input_files(args):
    sample_info = generate_sample_grouping(args.key, args.comparisons)
    mapping = generate_mapping_dict(args.mapping, sample_info)
    write_input_files(mapping, sample_info, args.strandedness, args.output, args.fq_pattern)

def generate_sample_grouping(key, comps):
    if not key and not comps:
        return None

    samp_info = {
        'key': dict(),
        'comps': set()
    }

    if key:
        with open(key, 'r') as f:
            for line in f:
                line = line.strip().split("\t")
                if line[0] in samp_info['key'].keys():
                    print("ERROR: sample {} in key file twice".format(line[0]))
                    sys.exit(1)
                if "_EXCLUDE_" in line[1]:
                    continue
                samp_info['key'][line[0]] = line[1]
    elif comps:
        print("ERROR: Cannot do anything with a comparisons files without key file. Either add key file or remove comparisons file from input")
        sys.exit(1)

    if comps:
        with open(comps, 'r') as f:
            for line in f:
                samp_info['comps'].add(tuple(line.strip().split("\t")))

    return samp_info

def write_input_files(mapping, samp_info, strandedness, output, fq_pattern):

    key_header = ""
    rep_count = dict()
    if samp_info:
        key_header = ",condition,replicate,batch"

    outfile = open(output, 'w')
    print("sample,fastq_1,fastq_2,strandedness{}".format(key_header), file=outfile)
    
    for sample in mapping:
        rep_count = print_input_lines(sample, mapping, strandedness, outfile, fq_pattern, samp_info, rep_count)

    outfile.close()

    if samp_info['comps']:
        outfile = open("contrasts.csv", 'w')
        print('id,variable,reference,target', file=outfile)
        for (ref,target) in samp_info['comps']:
            cid = "_".join(["condition", target,"vs",ref])
            print(cid,"condition",ref,target, sep=",", file=outfile)
        outfile.close()

def print_input_lines(sample, mapping, strandedness, outfile, fq_pattern, samp_info=None, rep_count=None):
    key_section = None
    if samp_info:
        cond = samp_info['key'][sample]
        if not cond in rep_count.keys():
            rep_count[cond] = 0
        rep_count[cond] = rep_count[cond] + 1
        key_section = ",".join([cond, str(rep_count[cond]), "A"])

    for fq_path in mapping[sample]:
        fq_r1s = glob.glob(fq_path + fq_pattern)
        if not fq_r1s:
            print("No fastq files found for sample: {} in path {}. Will be skipped.".format(sample, fq_path))
            return rep_count
        for fq_r1 in fq_r1s:
            fq_r2 = re.sub(r'_R1_', '_R2_', fq_r1)
            if not glob.glob(fq_r2):
                fq_r2 = ""
            if key_section:
                print(sample, fq_r1, fq_r2, strandedness, key_section, sep=',', file=outfile)
            else:
                print(sample, fq_r1, fq_r2, strandedness, sep=',', file=outfile)
    return rep_count

def generate_mapping_dict(mapping, samp_info=None):
    mapping_dict = {}
    with open(mapping, 'r') as f:
        for line in f:
            line = line.strip().split('\t')

            if samp_info and not line[1] in samp_info['key'].keys():
                continue

            if line[1] not in mapping_dict:
                mapping_dict[line[1]] = [line[3]]
            else:
                mapping_dict[line[1]].append(line[3])

    return mapping_dict

if __name__ == '__main__':
    args = parse_args()
    generate_input_files(args)
