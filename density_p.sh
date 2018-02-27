#!/bin/bash

export GMX_MAXBACKUP=-1

function print_usage() {
    echo "${0} root_dir lipid0_name ([SOPC/SDPC]) lipid1_name ([TSPC])"
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

./splitleafs/splitleafs.py --atom P -- "${IN_DIR}/step7_1.gro" > "${INDEX}"

gmx make_ndx -n "${INDEX}" -f "${IN_DIR}/step7_1.gro" -o "${INDEX}" <<EOF
r ${LIPID0} | r ${LIPID1}
1 & r ${LIPID0}
1 & r ${LIPID1}
q
EOF

# 0 P atoms of lower_leaflet
# 1 P atoms of upper_leaflet
# 2 bilayer membrane
# 3 P atoms SOPC/SDPC of upper_leaflet
# 4 P atoms TSPC of upper_leaflet

gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${INDEX}" -sl 400 -o "${OUT_DIR}/phosph_up.xvg" <<EOF &
2
1
EOF
gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${INDEX}" -sl 400 -o "${OUT_DIR}/phosph_lo.xvg" <<EOF &
2
0
EOF
gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${INDEX}" -sl 400 -o "${OUT_DIR}/phosph_up_${LIPID0}.xvg" <<EOF &
2
3
EOF
gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${INDEX}" -sl 400 -o "${OUT_DIR}/phosph_up_${LIPID1}.xvg" <<EOF &
2
4
EOF

wait
