#!/bin/bash

export GMX_MAXBACKUP=-1

function print_usage() {
    echo "${0} root_dir lipid_name sn1_n sn2_n tspc_sym"
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
readonly TSPC_SYM="${5}"

# create output directory
if [ ! -e "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

function make_carbon_ndx() {
    local c_pre=(3 2)
    eval local -a sn_c=$1
    local lipid0=$2
    local lipid1=$3
    local calc_upper=$4
    local calc_lower=$5

    for i in `seq 0 1`; do
        local ci="${c_pre[$i]}"
        for j in `seq 3 ${sn_c[$i]}`; do
            index="${OUT_DIR}/${lipid0}_c${ci}${j}.ndx"
            selstr="a C${ci}${j} & r ${lipid0}"
            gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o ${index} <<EOF
del 1-4
${selstr}
q
EOF
            ./splitleafs/splitleafs.py -a ${lipid0}:P ${lipid1}:P --keep-residue -- "${IN_DIR}/step7_1.gro" >> ${index}
            if $calc_upper; then
                gmx make_ndx -n ${index} -f "${IN_DIR}/step7_1.gro" -o ${index} <<EOF
1 & 3
q
EOF
            fi
            if $calc_lower; then
                gmx make_ndx -n ${index} -f "${IN_DIR}/step7_1.gro" -o ${index} <<EOF
1 & 2
q
EOF
            fi
        done
    done
}

function calc_density() {
    local c_pre=(3 2)
    eval local -a sn_c=$1
    local lipid=$2
    local calc_upper=$3
    local calc_lower=$4
    for i in `seq 0 1`; do
        local ci="${c_pre[$i]}"
        for j in `seq 3 ${sn_c[$i]}`; do
            index="${OUT_DIR}/${lipid}_c${ci}${j}.ndx"
	          gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${index}" -sl 400 -o "${OUT_DIR}/${lipid}_c${ci}${j}_tot.xvg" <<EOF &
0
1
EOF
            if $calc_upper; then
                gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${index}" -sl 400 -o "${OUT_DIR}/${lipid}_c${ci}${j}_hi.xvg" <<EOF &
0
4
EOF
            fi
            if $calc_lower; then
                gmx density -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -relative -center -nosymm -dens number -d Z -n "${index}" -sl 400 -o "${OUT_DIR}/${lipid}_c${ci}${j}_lo.xvg" <<EOF &
0
5
EOF
            fi
        done
        wait
    done
    wait
}

lipid_cs=("${SN1_N}" "${SN2_N}")
make_carbon_ndx "(${lipid_cs[*]})" "${LIPID}" "TSPC" true true
calc_density "(${lipid_cs[*]})" "${LIPID}" true true

tspc_cs=(32 18)
make_carbon_ndx "(${tspc_cs[*]})" "TSPC" "${LIPID}" true "${TSPC_SYM}"
calc_density "(${tspc_cs[*]})" "TSPC" true "${TSPC_SYM}"
