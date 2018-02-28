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
readonly LIPID="${2}"
readonly SN1_N="${3}"
readonly SN2_N="${4}"
readonly TSPC_EXIST="${5}"

# create output directory
if [ ! -e "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

SELSTR=""
readonly INDEX="${OUT_DIR}/carbon_tot.ndx"
readonly OUT_FILE="${OUT_DIR}/carbon_tot.xvg"

function append_selstr() {
    local c_pre=(3 2)
    eval local -a sn_c=$1
    for i in `seq 0 1`; do
        local ci="${c_pre[$i]}"
        for j in `seq 3 ${sn_c[$i]}`; do
            SELSTR="${SELSTR} | a C${ci}${j}"
        done
    done
}

function make_carbon_ndx() {
    SELSTR="${SELSTR:3}"
    gmx make_ndx -n "${IN_DIR}/index.ndx" -f "${IN_DIR}/step7_1.gro" -o "${INDEX}" <<EOF
del 1
${SELSTR}
q
EOF
    ./splitleafs/splitleafs.py --atom P --keep-residue -- "${IN_DIR}/step7_1.gro" >> ${INDEX}
    gmx make_ndx -n "${INDEX}" -o "${INDEX}" <<EOF
2 & 1
3 & 1
del 2-3
q
EOF
}

if ${TSPC_EXIST}; then
    tspc_cs=(32 18)
    append_selstr "(${tspc_cs[*]})"
fi

lipid_cs=("${SN1_N}" "${SN2_N}")
append_selstr "(${lipid_cs[*]})"
make_carbon_ndx

gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${INDEX}" -sl 400 -o "${OUT_DIR}/carbon_tot.xvg" <<EOF
0
1
EOF

gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${INDEX}" -sl 400 -o "${OUT_DIR}/carbon_tot_lo.xvg" <<EOF
0
2
EOF

gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${INDEX}" -sl 400 -o "${OUT_DIR}/carbon_tot_up.xvg" <<EOF
0
3
EOF
