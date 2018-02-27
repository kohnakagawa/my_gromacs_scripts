#!/bin/bash

export GMX_MAXBACKUP=-1

function print_usage() {
    echo "${0} root_dir lipid0_name lipid1_name"
    exit
}

if [ "$#" -ne 3 ]; then
    print_usage "${0}"
fi

# parse argument values
readonly IN_DIR="${1}"
readonly OUT_DIR="${1}/density"
readonly LIPID0="${2}"
readonly LIPID1="${3}"
readonly INDEX="${OUT_DIR}/phosph.ndx"

# create output directory
if [ ! -e "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${INDEX}" <<EOF
del 0-4
r ${LIPID0} | r ${LIPID1}
q
EOF
./splitleafs/splitleafs.py --atom P -- "${IN_DIR}/step7_1.gro" >> "${INDEX}"

gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${INDEX}" -sl 400 -o "${OUT_DIR}/phosph_up.xvg" <<EOF
0
2
EOF
gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${INDEX}" -sl 400 -o "${OUT_DIR}/phosph_lo.xvg" <<EOF
0
1
EOF
