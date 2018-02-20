#!/bin/bash

export GMX_MAXBACKUP=-1

function print_usage {
    echo "${0} root_dir lipid_name begin end"
    exit
}

if [ "$#" -ne 4 ]; then
    print_usage "${0}"
fi

# parse argument values
readonly IN_DIR="${1}"
readonly OUT_DIR="${1}/single"
readonly LIPID="${2}"
readonly BEG="${3}"
readonly END="${4}"

# create output directory
if [ ! -e "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

# create single lipid molecule index
gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/single.ndx" <<EOF
del 0-4
r ${LIPID}
q
EOF

# extract lipid trajectory
# NOTE: for-loop is processed parallelly.
xtcs=""
for i in `seq ${BEG} ${END}`
do
    out_xtc="${OUT_DIR}/step7_${i}_single.xtc"
    gmx trjconv -pbc mol -center -s "${IN_DIR}/step7_${i}.tpr" -f "${IN_DIR}/step7_${i}.trr" \
        -n "${OUT_DIR}/single.ndx" -o "${out_xtc}" > /dev/null 2>&1 &
    xtcs="${xtcs} ${out_xtc}"
done

sleep 10

# merge lipid trajectory
gmx trjcat -f ${xtcs} -o "${OUT_DIR}/merged_single.xtc"

# dump single molecule configuration
gmx trjconv -pbc mol -center -s "${IN_DIR}/step7_1.tpr" -f "${IN_DIR}/step7_1.gro" -n "${OUT_DIR}/single.ndx" -o "${OUT_DIR}/step7_1_single.gro"
