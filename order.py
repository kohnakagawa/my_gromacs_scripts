import numpy as np
import MDAnalysis as mda
import argparse
import os
import sys

def sn_to_index(sn_name):
    if sn_name == "sn1":
        return 3
    elif sn_name == "sn2":
        return 2
    else:
        print("invalid sn name {}".format(sn_name))
        sys.exit(1)


def get_bilayer_center(univ):
    lipid_atoms = univ.select_atoms("name P")
    return lipid_atoms.center_of_geometry()[2]


def get_bilayer_res(univ, lipid):
    bcenter = get_bilayer_center(univ)
    upper_res_ids = ["resid " + str(rid) for rid in univ.select_atoms("resname {} and name P and prop z >  {}".format(lipid, bcenter)).resids]
    lower_res_ids = ["resid " + str(rid) for rid in univ.select_atoms("resname {} and name P and prop z <= {}".format(lipid, bcenter)).resids]
    res_all = "resname {}".format(lipid)

    if lower_res_ids == []:
        return (("upper",), (" or ".join(upper_res_ids),))
    else:
        return (("upper", "lower", "tot"), (" or ".join(upper_res_ids), " or ".join(lower_res_ids), res_all))


def calc_scd(cs, hs, cn, box):
    c2d = hs.positions - cs.positions
    c2d -= box * np.round(c2d / box)

    c2d_norm = np.sqrt(np.sum(np.power(c2d, 2), axis=1))
    c2d_norm.shape = (len(c2d_norm), 1)
    c2d = c2d / c2d_norm

    # (3.0 * cos_theta ** 2 - 1.0) / 2.0
    order = 1.5 * c2d[:,2] * c2d[:,2] - 0.5
    order = np.reshape(order, (cn, -1), order='F')
    order = np.average(order, axis=1)
    return order


def selstr_carbons(beg, end, sn):
    sn = sn_to_index(sn)
    return " or ".join(["name C{}{}".format(sn, i) for i in range(beg, end+1)])


def h_exits(univ, lipid, hydro):
    return len(univ.select_atoms("{} and {}".format(lipid, hydro))) != 0


def selstr_hydrogens(univ, lipid, beg, end, sn, h_ind):
    lipid = "resname {}".format(lipid)
    h_suffixes = (
        'X' if sn == "sn1" else 'R',
        'Y' if sn == "sn1" else 'S',
        'Z' if sn == "sn1" else 'T',
    )

    sn = sn_to_index(sn)
    h_suffix = h_suffixes[h_ind]

    hydrogens = []
    for i in range(beg, end + 1):
        hname0 = "name H{}{}".format(i, h_suffix)
        hname1 = "name H{}{}".format(i, 1)
        if h_exits(univ, lipid, hname0):
            hydrogens.append(hname0)
        elif h_exits(univ, lipid, hname1):
            hydrogens.append(hname1)
        else:
            hydrogens.append("name H{}{}".format(i, h_suffixes[0]))

    return " or ".join(hydrogens)


def main(input_dir, lipid, cs_begs, cs_ends):
    trr_file = os.path.join(input_dir, "merged_trr", "merged_tot.trr")
    # trr_file = os.path.join(input_dir, "step7_1.trr")
    tpr_file = os.path.join(input_dir, "step7_1.tpr")

    univ = mda.Universe(tpr_file, trr_file)
    sns = ("sn1", "sn2")

    out_dir = os.path.join(input_dir, "scd")
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    res_labels, res_searched = get_bilayer_res(univ, lipid)
    for res, label in zip(res_searched, res_labels):
        for i, sn in enumerate(sns):
            cns = cs_ends[i] - cs_begs[i] + 1
            scd_sn = np.zeros(cns)

            cs_selstr  = selstr_carbons(cs_begs[i], cs_ends[i], sn)
            h0s_selstr = selstr_hydrogens(univ, lipid, cs_begs[i], cs_ends[i], sn, 0)
            h1s_selstr = selstr_hydrogens(univ, lipid, cs_begs[i], cs_ends[i], sn, 1)
            h2s_selstr = selstr_hydrogens(univ, lipid, cs_begs[i], cs_ends[i], sn, 2)

            cs  = univ.select_atoms("({}) and ({})".format(res, cs_selstr))
            h0s = univ.select_atoms("({}) and ({})".format(res, h0s_selstr))
            h1s = univ.select_atoms("({}) and ({})".format(res, h1s_selstr))
            h2s = univ.select_atoms("({}) and ({})".format(res, h2s_selstr))

            for _ in univ.trajectory:
                box = univ.dimensions[0:3]
                scd_sn += calc_scd(cs, h0s, cns, box)
                scd_sn += calc_scd(cs, h1s, cns, box)
                scd_end = calc_scd(cs, h2s, cns, box)
                scd_end[0:-1] = 0.0
                scd_sn += scd_end

            weight = np.full([cns], 1.0 / 2.0)
            weight[-1] = 1.0 / 3.0 # ASSUME: scd[-1] is a methyl group.
            weight = weight / float(len(univ.trajectory))
            scd_sn *= weight

            out_file = os.path.join(out_dir, "{}_{}_{}_scd.txt".format(lipid, sn, label))
            sn_idxes = range(cs_begs[i], cs_ends[i] + 1)
            with open(out_file, "w") as f:
                for (sn_idx, scd) in zip(sn_idxes, scd_sn):
                    f.write("{:d} {:.10g}\n".format(sn_idx, scd))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Calculate deuterium order parameter of bilayer membrane.")
    parser.add_argument('-i', '--input', dest='input_dir', required=True, help="input directory name")
    parser.add_argument('-l', '--lipid', dest='lipid', required=True, help="lipid name")
    parser.add_argument('-b1', '--bsn1', dest='bsn1', required=True, help="sn1", type=int)
    parser.add_argument('-e1', '--esn1', dest='esn1', required=True, help="sn1", type=int)
    parser.add_argument('-b2', '--bsn2', dest='bsn2', required=True, help="sn2", type=int)
    parser.add_argument('-e2', '--esn2', dest='esn2', required=True, help="sn2", type=int)

    args = parser.parse_args()
    main(args.input_dir, args.lipid, (args.bsn1, args.bsn2), (args.esn1, args.esn2))
