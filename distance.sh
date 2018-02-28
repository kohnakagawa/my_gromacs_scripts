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

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/c3_c18_sn1_tspc.ndx" <<EOF
del 0-4
a C33 | a C318
r TSPC
0 & 1
del 0-1
q
EOF

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/c3_c18_sn2_tspc.ndx" <<EOF
del 0-4
a C23 | a C218
r TSPC
0 & 1
del 0-1
q
EOF

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/c3_c18_sn1_sopc.ndx" <<EOF
del 0-4
a C33 | a C318
r SOPC
0 & 1
del 0-1
q
EOF

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/c3_c18_sn2_sopc.ndx" <<EOF
del 0-4
a C23 | a C218
r SOPC
0 & 1
del 0-1
q
EOF

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/c18_c32_tspc.ndx" <<EOF
del 0-4
a C318 | a C332
r TSPC
0 & 1
del 0-1
q
EOF

gmx make_ndx -f "${IN_DIR}/step7_1.gro" -o "${OUT_DIR}/c3_c32_tspc.ndx" <<EOF
del 0-4
a C33 | a C332
r TSPC
0 & 1
del 0-1
q
EOF

gmx distance -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -n "${OUT_DIR}/c3_c18_sn1_tspc.ndx" -oav "${OUT_DIR}/c3_c18_sn1_tspc_aver.xvg" -oall "${OUT_DIR}/c3_c18_sn1_tspc.xvg" -oh "${OUT_DIR}/c3_c18_sn1_tspc_hist.xvg" <<EOF
0
EOF

gmx distance -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -n "${OUT_DIR}/c3_c18_sn2_tspc.ndx" -oav "${OUT_DIR}/c3_c18_sn2_tspc_aver.xvg" -oall "${OUT_DIR}/c3_c18_sn2_tspc.xvg" -oh "${OUT_DIR}/c3_c18_sn2_tspc_hist.xvg" <<EOF
0
EOF

gmx distance -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -n "${OUT_DIR}/c3_c18_sn1_sopc.ndx" -oav "${OUT_DIR}/c3_c18_sn1_sopc_aver.xvg" -oall "${OUT_DIR}/c3_c18_sn1_sopc.xvg" -oh "${OUT_DIR}/c3_c18_sn1_sopc_hist.xvg" <<EOF
0
EOF

gmx distance -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -n "${OUT_DIR}/c3_c18_sn2_sopc.ndx" -oav "${OUT_DIR}/c3_c18_sn2_sopc_aver.xvg" -oall "${OUT_DIR}/c3_c18_sn2_sopc.xvg" -oh "${OUT_DIR}/c3_c18_sn2_sopc_hist.xvg" <<EOF
0
EOF

gmx distance -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -n "${OUT_DIR}/c18_c32_tspc.ndx" -oav "${OUT_DIR}/c18_c32_tspc_aver.xvg" -oall "${OUT_DIR}/c18_c32_tspc.xvg" -oh "${OUT_DIR}/c18_c32_tspc_hist.xvg" <<EOF
0
EOF

gmx distance -f "${IN_DIR}/merged_trr/merged_tot.trr" -s "${IN_DIR}/step7_1.tpr" -n "${OUT_DIR}/c3_c32_tspc.ndx" -oav "${OUT_DIR}/c3_c32_tspc_aver.xvg" -oall "${OUT_DIR}/c3_c32_tspc.xvg" -oh "${OUT_DIR}/c3_c32_tspc_hist.xvg" <<EOF
0
EOF
