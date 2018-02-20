#!/bin/bash

export GMX_MAXBACKUP=-1

function print_usage {
    echo "${0} root_dir begin end"
    exit
}

if [ "$#" -ne 3 ]; then
    print_usage "${0}"
fi

# parse argument values
readonly IN_DIR="${1}"
readonly OUT_DIR="${1}/merged_trr"
readonly BEG="${2}"
readonly END="${3}"

# create output directory
if [ ! -e "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

trrs=""
for i in `seq ${BEG} ${END}`
do
    trrs="${trrs} ${IN_DIR}/step7_${i}.trr"
done

gmx trjcat -f ${trrs} -o "${OUT_DIR}/merged_tot.trr"

