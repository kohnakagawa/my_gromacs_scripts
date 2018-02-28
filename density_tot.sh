#!/bin/bash

export GMX_MAXBACKUP=-1

function print_usage() {
    echo "${0} root_dir lipid_name sn1_n sn2_n tspc_exist"
    exit
}

if [ "$#" -ne 5 ]; then
    print_usage "${0}"
fi

# parse argument values
readonly IN_DIR="${1}"
readonly OUT_DIR="${1}/density"
readonly INDEX="${1}/index.ndx"

# create output directory
if [ ! -e "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${INDEX}" -sl 400 -o "${OUT_DIR}/membrane.xvg" <<EOF
0
0
EOF
