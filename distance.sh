#!/bin/bash

export GMX_MAXBACKUP=-1

function print_usage {
    echo "${0} root_dir"
    exit
}

if [ "$#" -ne 1 ]; then
    print_usage "${0}"
fi

# parse argument values
readonly IN_DIR="${1}"
readonly OUT_DIR="${1}/distance"

# create output directory
if [ ! -e "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/c3_c18.ndx" <<EOF
del 0-4
a C33 | a C318
r TSPC
0 & 1
del 0-1
q
EOF

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/c18_c32.ndx" <<EOF
del 0-4
a C318 | a C332
r TSPC
0 & 1
del 0-1
q
EOF

gmx distance -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -n "${OUT_DIR}/c3_c18.ndx" -oav "${OUT_DIR}/c3_c18_aver.xvg" -oall "${OUT_DIR}/c3_c18.xvg" -oh "${OUT_DIR}/c3_c18_hist.xvg" <<EOF
0
EOF
gmx distance -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -n "${OUT_DIR}/c18_c32.ndx" -oav "${OUT_DIR}/c18_c32_aver.xvg" -oall "${OUT_DIR}/c18_c32.xvg" -oh "${OUT_DIR}/c18_c32_hist.xvg" <<EOF
0
EOF
