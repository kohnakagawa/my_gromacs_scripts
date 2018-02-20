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


def main(input_dir, lipid):
    set_font()
    set_label("Carbon", r"$|S_{\mathrm{CD}}|$")

    scd_sn1 = np.loadtxt(os.path.join(input_dir, "{}_sn1_scd.txt".format(lipid)))
    scd_sn2 = np.loadtxt(os.path.join(input_dir, "{}_sn2_scd.txt".format(lipid)))

    # set_ticks(
    #     (3, 32, 4),
    #     (0.03, 0.25, 0.05)
    # )
    set_ticks(
        (3, 18, 2),
        (0.03, 0.25, 0.05)
    )

    # plt.xlim(2, 33)
    plt.xlim(2, 19)
    plt.ylim(0.0, 0.24)

    plt.plot(scd_sn1[:,0], np.abs(scd_sn1[:,1]), '-o', label="sn1")
    plt.plot(scd_sn2[:,0], np.abs(scd_sn2[:,1]), '-o', label="sn2")

    plt.tight_layout()

    plt.legend()

    plt.savefig(os.path.join(input_dir, "{}_scd.eps".format(lipid)))

    # for check
    # plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot deuterium order parameter of lipid bilayer membrane")
    parser.add_argument('-i', '--input', dest='input_dir', required=True, help="input directory name")
    parser.add_argument('-l', '--lipid', dest='lipid', required=True, help="lipid name")
    args = parser.parse_args()
    main(args.input_dir, args.lipid)
