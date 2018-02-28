#!/usr/bin/env python
import numpy as np
import matplotlib.pyplot as plt
import argparse
import os

def set_font():
    plt.rcParams["font.size"] = 20
    plt.rcParams["font.family"] = 'serif'


def set_label(x_name, y_name):
    plt.xlabel(x_name)
    plt.ylabel(y_name)


def set_ticks(x_range, y_range):
    plt.xticks(np.arange(*x_range))
    plt.yticks(np.arange(*y_range))


def exist_lower_leaflet(input_dir, lipid):
    in_file = os.path.join(input_dir, "{}_sn1_lower_scd.txt".format(lipid))
    return os.path.exists(in_file)


def main(input_dir, lipids):
    set_font()
    set_label("Carbon", r"$|S_{\mathrm{CD}}|$")

    for lipid in lipids:
        exist_lleaf = exist_lower_leaflet(input_dir, lipid)

        scd_sn1_u = np.loadtxt(os.path.join(input_dir, "{}_sn1_upper_scd.txt".format(lipid)))
        scd_sn2_u = np.loadtxt(os.path.join(input_dir, "{}_sn2_upper_scd.txt".format(lipid)))
        if exist_lleaf:
            scd_sn1_l = np.loadtxt(os.path.join(input_dir, "{}_sn1_lower_scd.txt".format(lipid)))
            scd_sn2_l = np.loadtxt(os.path.join(input_dir, "{}_sn2_lower_scd.txt".format(lipid)))

        c_numbers = np.append(scd_sn1_u[:,0], scd_sn2_u[:,0])
        c_number_min = np.min(c_numbers)
        c_number_max = np.max(c_numbers)
        set_ticks(
            (c_number_min, c_number_max, 2),
            (0.03, 0.35, 0.05)
        )

        plt.xlim(c_number_min - 1, c_number_max + 1)
        plt.ylim(0.0, 0.25)

        plt.plot(scd_sn1_u[:,0], np.abs(scd_sn1_u[:,1]), '-o', label="{} sn1 upper".format(lipid))
        plt.plot(scd_sn2_u[:,0], np.abs(scd_sn2_u[:,1]), '-o', label="{} sn2 upper".format(lipid))
        if exist_lleaf:
            plt.plot(scd_sn1_l[:,0], np.abs(scd_sn1_l[:,1]), '-o', label="{} sn1 lower".format(lipid))
            plt.plot(scd_sn2_l[:,0], np.abs(scd_sn2_l[:,1]), '-o', label="{} sn2 lower".format(lipid))

    plt.tight_layout()

    plt.legend(fontsize=16)

    plt.savefig(os.path.join(input_dir, "{}_scd.eps".format("_".join(lipids))))

    # for check
    # plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot deuterium order parameter of lipid bilayer membrane")
    parser.add_argument('-i', '--input', dest='input_dir', required=True, help="input directory name")
    parser.add_argument('-l', '--lipids', nargs="+", dest='lipids', required=True, help="names of lipids")
    args = parser.parse_args()
    main(args.input_dir, args.lipids)
