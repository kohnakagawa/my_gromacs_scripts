#!/bin/bash

export GMX_MAXBACKUP=-1

function print_usage {
    echo "${0} root_dir begin end"
    exit
}

if [ "$#" -ne 3 ]; then
    print_usage "${0}"
fi

readonly OUTDIR="${1}/area"
if [ ! -e "${OUTDIR}" ]; then
    mkdir "${OUTDIR}"
fi

edrs=""
for i in `seq ${2} ${3}`
do
    edr_name="${1}/step7_${i}.edr"
    edrs="${edrs} ${edr_name}"
done

gmx eneconv -f ${edrs} -o "${OUTDIR}/merged.edr"
gmx energy -f "${OUTDIR}/merged.edr" -o "${OUTDIR}/Lx.xvg" <<EOF
16 0
EOF
gmx energy -f "${OUTDIR}/merged.edr" -o "${OUTDIR}/Ly.xvg" <<EOF
17 0
EOF
gmx energy -f "${OUTDIR}/merged.edr" -o "${OUTDIR}/stens.xvg" <<EOF
41 0
EOF

sed -i -e "s/@/#/g" "${OUTDIR}/Lx.xvg"
sed -i -e "s/@/#/g" "${OUTDIR}/Ly.xvg"
sed -i -e "s/@/#/g" "${OUTDIR}/stens.xvg"
