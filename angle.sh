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
readonly OUT_DIR="${1}/angle"

# create output directory
if [ ! -e "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/angle_mol.ndx" <<EOF
del 0-4
a C33 | a C318 | a C332
r TSPC
0 & 1
del 0-1
q
EOF

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/angle_z.ndx" <<EOF
del 0-4
a C318 | a C332
r TSPC
0 & 1
del 0-1
q
EOF

gmx gangle -f "${IN_DIR}/merged_trr/merged_tot.trr" -n "${OUT_DIR}/angle_mol.ndx" -s "${IN_DIR}/step7_1.tpr" -oh "${OUT_DIR}/ang_mol_hist.xvg" -oav "${OUT_DIR}/ang_mol_aver.xvg" -oall "${OUT_DIR}/angles_mol.xvg" <<EOF
0
EOF
gmx gangle -f "${IN_DIR}/merged_trr/merged_tot.trr" -n "${OUT_DIR}/angle_z.ndx" -s "${IN_DIR}/step7_1.tpr" -oh "${OUT_DIR}/ang_z_hist.xvg" -oav "${OUT_DIR}/ang_z_aver.xvg" -oall "${OUT_DIR}/angles_z.xvg" -g1 vector -g2 z <<EOF
0
EOF

